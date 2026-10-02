// Firestore security rules tests for AcadAI Buddy.
// Run from this folder:  npm test   (starts the emulator, runs, stops it)

import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

let env;
const chat = (owner, extra = {}) => ({
  id: 'c1',
  ownerId: owner,
  subject: 'Data Structures & Algorithms',
  title: 'Base case',
  lastMessage: 'hi',
  createdAt: new Date(),
  updatedAt: new Date(),
  ...extra,
});
const msg = { id: 'm1', content: 'hi', role: 'user', timestamp: new Date(), chatId: 'c1' };

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-acadai',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});
after(async () => env?.cleanup());
beforeEach(async () => env.clearFirestore());

const db = (uid) =>
  uid ? env.authenticatedContext(uid).firestore() : env.unauthenticatedContext().firestore();

/** Seeds data with rules disabled. */
async function seed(fn) {
  await env.withSecurityRulesDisabled(async (ctx) => fn(ctx.firestore()));
}

describe('users', () => {
  test('owner reads and writes profile and quiz results', async () => {
    const d = db('alice');
    await assertSucceeds(setDoc(doc(d, 'users/alice'), { displayName: 'Alice' }));
    await assertSucceeds(getDoc(doc(d, 'users/alice')));
    await assertSucceeds(setDoc(doc(d, 'users/alice/quizResults/r1'), { score: 8, total: 10 }));
    await assertSucceeds(getDocs(collection(d, 'users/alice/quizResults')));
  });

  test('others and signed-out users cannot', async () => {
    await assertFails(getDoc(doc(db('bob'), 'users/alice')));
    await assertFails(setDoc(doc(db('bob'), 'users/alice/quizResults/r1'), { score: 10 }));
    await assertFails(getDocs(collection(db('bob'), 'users/alice/quizResults')));
    await assertFails(getDoc(doc(db(null), 'users/alice')));
  });
});

describe('chats', () => {
  test('first message: chat + message in one batch (what the app does)', async () => {
    const d = db('alice');
    const b = writeBatch(d);
    b.set(doc(d, 'chats/c1'), chat('alice'), { merge: true });
    b.set(doc(d, 'chats/c1/messages/m1'), msg);
    await assertSucceeds(b.commit());
  });

  test('cannot create a chat for someone else', async () => {
    await assertFails(setDoc(doc(db('alice'), 'chats/c1'), chat('bob')));
    await assertFails(setDoc(doc(db(null), 'chats/c1'), chat('alice')));
  });

  test('a new chat screen may read a chat that does not exist yet', async () => {
    await assertSucceeds(getDoc(doc(db('alice'), 'chats/new')));
    await assertFails(getDoc(doc(db(null), 'chats/new')));
  });

  test('owner reads; stranger cannot read, update or delete', async () => {
    await seed((d) => setDoc(doc(d, 'chats/c1'), chat('alice')));
    await assertSucceeds(getDoc(doc(db('alice'), 'chats/c1')));
    await assertFails(getDoc(doc(db('bob'), 'chats/c1')));
    await assertFails(setDoc(doc(db('bob'), 'chats/c1'), chat('bob')));
    await assertFails(deleteDoc(doc(db('bob'), 'chats/c1')));
  });

  test('owner can rename / update but cannot give the chat away', async () => {
    await seed((d) => setDoc(doc(d, 'chats/c1'), chat('alice')));
    const d = db('alice');
    await assertSucceeds(setDoc(doc(d, 'chats/c1'), chat('alice', { title: 'Renamed' }), { merge: true }));
    await assertFails(setDoc(doc(d, 'chats/c1'), { ownerId: 'bob' }, { merge: true }));
  });

  test('history query filtered by ownerId works; unfiltered is denied', async () => {
    await seed(async (d) => {
      await setDoc(doc(d, 'chats/c1'), chat('alice'));
      await setDoc(doc(d, 'chats/c2'), chat('bob', { id: 'c2' }));
    });
    const d = db('alice');
    const mine = await assertSucceeds(getDocs(query(collection(d, 'chats'), where('ownerId', '==', 'alice'))));
    if (mine.size !== 1) throw new Error(`expected 1 chat, got ${mine.size}`);
    await assertFails(getDocs(collection(d, 'chats')));
    await assertFails(getDocs(query(collection(d, 'chats'), where('ownerId', '==', 'bob'))));
  });
});

describe('messages', () => {
  beforeEach(async () => {
    await seed(async (d) => {
      await setDoc(doc(d, 'chats/c1'), chat('alice'));
      await setDoc(doc(d, 'chats/c1/messages/m1'), msg);
    });
  });

  test('owner reads, lists, writes and deletes messages', async () => {
    const d = db('alice');
    await assertSucceeds(getDocs(collection(d, 'chats/c1/messages')));
    await assertSucceeds(setDoc(doc(d, 'chats/c1/messages/m2'), { ...msg, id: 'm2' }));
    await assertSucceeds(deleteDoc(doc(d, 'chats/c1/messages/m2')));
  });

  test('stranger cannot read or write messages', async () => {
    const d = db('bob');
    await assertFails(getDocs(collection(d, 'chats/c1/messages')));
    await assertFails(getDoc(doc(d, 'chats/c1/messages/m1')));
    await assertFails(setDoc(doc(d, 'chats/c1/messages/m9'), msg));
  });

  test('messages of a chat that does not exist cannot be written alone', async () => {
    await assertFails(setDoc(doc(db('alice'), 'chats/ghost/messages/m1'), msg));
  });

  test('delete chat: messages and chat doc in one batch', async () => {
    const d = db('alice');
    const b = writeBatch(d);
    b.delete(doc(d, 'chats/c1/messages/m1'));
    b.delete(doc(d, 'chats/c1'));
    await assertSucceeds(b.commit());
  });

  test('clear chat: delete messages and reset lastMessage in one batch', async () => {
    const d = db('alice');
    const b = writeBatch(d);
    b.delete(doc(d, 'chats/c1/messages/m1'));
    b.set(doc(d, 'chats/c1'), chat('alice', { lastMessage: '' }), { merge: true });
    await assertSucceeds(b.commit());
  });
});
