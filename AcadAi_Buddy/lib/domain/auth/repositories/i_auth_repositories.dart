// lib/domain/auth/repositories/i_auth_repositories.dart

import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/app_user.dart';

/// Abstract contract for all authentication operations.
///
/// Implementations live in `infrastructure/auth/`.
/// Consumers in the application layer depend only on this interface.
abstract class IAuthRepository {
  /// Signs in an existing user with [email] and [password].
  ///
  /// Returns [Right<AppUser>] on success, or a typed [Left<AuthFailure>]
  /// describing what went wrong.
  Future<Either<AuthFailure, AppUser>> signIn(
    String email,
    String password,
  );

  /// Creates a new account with [email], [password], and [displayName].
  ///
  /// Returns [Right<AppUser>] on success, or a typed [Left<AuthFailure>].
  /// A failed profile write after the account exists is not a failure; it is
  /// retried in the background.
  Future<Either<AuthFailure, AppUser>> signUp(
    String email,
    String password,
    String displayName,
  );

  /// Signs the currently authenticated user out.
  ///
  /// Completes normally if no user is signed in.
  Future<void> signOut();

  /// Returns the currently signed-in [AppUser], or `null` if unauthenticated.
  ///
  /// This is a synchronous snapshot; use [authStateChanges] to follow it.
  AppUser? getSignedInUser();

  /// Emits the signed-in user (or null) now and on every sign-in/out.
  Stream<AppUser?> authStateChanges();

  /// Sends a password-reset email to [email].
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail(String email);

  /// Changes the signed-in user's display name (auth profile and the
  /// `users/{uid}` document).
  Future<Either<AuthFailure, AppUser>> updateDisplayName(String displayName);
}
