import 'dart:async';

import 'package:study_ai_app/domain/auth/entities/app_user.dart';
import 'package:study_ai_app/domain/auth/repositories/i_auth_repositories.dart';
import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/infrastructure/auth/dtos/user_dto.dart';
import 'package:study_ai_app/infrastructure/core/firebase_injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthRepositoryProvider = Provider<IAuthRepository>(
  (ref) => FirebaseAuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  ),
);

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository(this._firebaseAuth, this._firestore);

  @override
  Future<Either<AuthFailure, AppUser>> signIn(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) return left(AuthFailure.serverError());
      return right(UserDto.fromFirebase(user).toDomain());
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure.fromCode(e.code));
    } catch (_) {
      return left(AuthFailure.serverError());
    }
  }

  @override
  Future<Either<AuthFailure, AppUser>> signUp(
      String email, String password, String displayName) async {
    final User user;
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) return left(AuthFailure.serverError());
      user = userCredential.user!;
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure.fromCode(e.code));
    } catch (_) {
      return left(AuthFailure.serverError());
    }

    // The account exists from here on: nothing below may fail the sign-up.
    try {
      await user.updateDisplayName(displayName);
    } catch (_) {
      // Display name is also stored in the profile document below.
    }

    final userDto = UserDto(
      id: user.uid,
      email: email,
      displayName: displayName,
    );
    unawaited(_writeProfile(userDto));

    return right(userDto.toDomain());
  }

  /// Writes the profile document, retrying a few times in the background.
  Future<void> _writeProfile(UserDto dto, [int attempt = 0]) async {
    try {
      await _firestore
          .collection('users')
          .doc(dto.id)
          .set(dto.toJson(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      if (attempt >= 3) return;
      await Future<void>.delayed(Duration(seconds: 5 * (attempt + 1)));
      await _writeProfile(dto, attempt + 1);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  AppUser? getSignedInUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserDto.fromFirebase(user).toDomain();
  }

  @override
  Stream<AppUser?> authStateChanges() => _firebaseAuth
      .authStateChanges()
      .map((u) => u == null ? null : UserDto.fromFirebase(u).toDomain());

  @override
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return right(unit);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure.fromCode(e.code));
    } catch (_) {
      return left(AuthFailure.serverError());
    }
  }
}
