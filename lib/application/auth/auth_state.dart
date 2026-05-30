// lib/application/auth/auth_state.dart

import 'package:study_ai_app/domain/auth/entities/app_user.dart';
import 'package:study_ai_app/domain/core/failures.dart';

abstract class AuthState {
  const AuthState();
}

/// Initial state before any auth check has been performed.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An async auth operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The user is signed in.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AppUser user;
}

/// No signed-in user.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An auth operation failed.
class AuthFailureState extends AuthState {
  const AuthFailureState(this.failure);
  final AuthFailure failure;

  /// Convenience getter — returns the human-readable message from the failure.
  String get message => failure.message;
}
