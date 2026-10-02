# Release checklist

Steps that need a person; the code side is already in place.

## 1. AI key (`.env`)

`.env` is bundled into the APK as an asset, so the key can be extracted from
any copy of the app.

- Rotate `OPENROUTER_API_KEY` in the OpenRouter dashboard and set a monthly
  spend limit on it.
- Copy `.env.example` to `.env` and fill in the new key. `.env` is git-ignored.
- Long term: run a small proxy (Cloudflare Worker, Vercel function, or a
  Firebase Function on the Blaze plan) that verifies the Firebase ID token
  and adds the key server-side. Then set `AI_BASE_URL` to the proxy and leave
  `OPENROUTER_API_KEY` empty in the app.

`AI_MODEL` / `AI_VISION_MODEL` default to `google/gemma-4-31b-it:free`. Free
models are rate-limited and can be withdrawn; change them in `.env` without a
code change.

## 2. Release signing

Without `android/key.properties` the release build is signed with the debug
key (Gradle prints a warning). To sign properly:

```
keytool -genkey -v -keystore C:/keys/acadai-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias acadai
```

Then create `android/key.properties` (git-ignored):

```
storeFile=C:/keys/acadai-release.jks
storePassword=...
keyAlias=acadai
keyPassword=...
```

Back up the `.jks` file and passwords; Play updates need the same key.

## 3. Firestore rules

`firestore.rules` restricts every chat, message and quiz result to its owner.
It is **not deployed**. Test it, then deploy:

```
firebase emulators:start --only firestore
firebase deploy --only firestore:rules
```

Chats created before this release have no `chats/{id}` document, so they are
not listed in the app and are not readable under these rules.

## 4. Build and smoke test

```
flutter build apk --release
```

On a physical device over mobile data: sign up, sign in, chat (text and a
photo), quiz, summarize, sign out.
