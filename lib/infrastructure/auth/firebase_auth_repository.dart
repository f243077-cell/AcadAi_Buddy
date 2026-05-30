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
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return left(AuthFailure.wrongPassword());
      } else if (e.code == 'user-not-found') {
        return left(AuthFailure.userNotFound());
      } else if (e.code == 'invalid-email') {
        return left(AuthFailure.invalidEmail());
      }
      return left(AuthFailure.serverError());
    } catch (_) {
      return left(AuthFailure.serverError());
    }
  }

  @override
  Future<Either<AuthFailure, AppUser>> signUp(
      String email, String password, String displayName) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) return left(AuthFailure.serverError());

      await user.updateDisplayName(displayName);
      await user.reload();

      final userDto = UserDto(
        id: user.uid,
        email: email,
        displayName: displayName,
      );

      await _firestore.collection('users').doc(user.uid).set(userDto.toJson());

      return right(userDto.toDomain());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return left(AuthFailure.emailAlreadyInUse());
      } else if (e.code == 'invalid-email') {
        return left(AuthFailure.invalidEmail());
      } else if (e.code == 'weak-password') {
        return left(AuthFailure.weakPassword());
      }
      return left(AuthFailure.serverError());
    } catch (_) {
      return left(AuthFailure.serverError());
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
}
