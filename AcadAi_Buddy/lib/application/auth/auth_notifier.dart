import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_ai_app/application/auth/auth_state.dart';
import 'package:study_ai_app/domain/auth/entities/app_user.dart';
import 'package:study_ai_app/domain/auth/repositories/i_auth_repositories.dart';
import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/infrastructure/auth/firebase_auth_repository.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;
  StreamSubscription<AppUser?>? _sub;

  AuthNotifier(this._authRepository) : super(const AuthInitial()) {
    _sub = _authRepository.authStateChanges().listen(
          _onAuthUser,
          onError: (_) => checkAuth(),
        );
  }

  void _onAuthUser(AppUser? user) {
    final s = state;
    // While a sign-in/up is running, its own result decides the state.
    if (s is AuthLoading) return;
    if (user != null) {
      // Keep the richer user from sign-up (it carries the display name).
      if (s is AuthAuthenticated && s.user.id == user.id) return;
      state = AuthAuthenticated(user);
    } else {
      // Keep a visible failure until the user edits the form.
      if (s is AuthFailureState) return;
      state = const AuthUnauthenticated();
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();
    final result = await _authRepository.signIn(email, password);
    if (!mounted) return;
    result.fold(
      (failure) => state = AuthFailureState(failure),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AuthLoading();
    final result = await _authRepository.signUp(email, password, name);
    if (!mounted) return;
    result.fold(
      (failure) => state = AuthFailureState(failure),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<Either<AuthFailure, Unit>> sendPasswordReset(String email) =>
      _authRepository.sendPasswordResetEmail(email);

  /// Clears a shown failure (called when the user edits the form).
  void clearError() {
    if (state is AuthFailureState) state = const AuthUnauthenticated();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AuthUnauthenticated();
  }

  /// Synchronous snapshot; kept for compatibility with older callers.
  void checkAuth() {
    final user = _authRepository.getSignedInUser();
    state =
        user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(firebaseAuthRepositoryProvider),
  );
});

/// The signed-in user, or null.
final currentUserProvider = Provider<AppUser?>((ref) {
  final s = ref.watch(authNotifierProvider);
  return s is AuthAuthenticated ? s.user : null;
});
