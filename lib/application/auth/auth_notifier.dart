import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_ai_app/application/auth/auth_state.dart';
import 'package:study_ai_app/domain/auth/repositories/i_auth_repositories.dart';
import 'package:study_ai_app/infrastructure/auth/firebase_auth_repository.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthInitial());

  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();
    final result = await _authRepository.signIn(email, password);
    result.fold(
      (failure) => state = AuthFailureState(failure),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AuthLoading();
    final result = await _authRepository.signUp(email, password, name);
    result.fold(
      (failure) => state = AuthFailureState(failure),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AuthUnauthenticated();
  }

  void checkAuth() {
    final user = _authRepository.getSignedInUser();
    state =
        user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(firebaseAuthRepositoryProvider),
  );
});
