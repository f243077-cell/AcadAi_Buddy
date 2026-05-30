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
  /// Note: a successful sign-up returns [Left<AuthFailure.emailNotVerified>]
  /// intentionally — the UI treats this as a success banner, not an error.
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
  /// Returns null for unverified users.
  /// This is a synchronous snapshot — it does not stream auth-state changes.
  AppUser? getSignedInUser();
}
