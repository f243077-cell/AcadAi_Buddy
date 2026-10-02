import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_ai_app/application/auth/auth_notifier.dart';
import 'package:study_ai_app/application/auth/auth_state.dart';
import 'package:study_ai_app/domain/auth/entities/app_user.dart';
import 'package:study_ai_app/domain/auth/repositories/i_auth_repositories.dart';
import 'package:study_ai_app/domain/core/failures.dart';

class _FakeAuthRepo implements IAuthRepository {
  final controller = StreamController<AppUser?>.broadcast();
  Either<AuthFailure, AppUser> signInResult =
      left(AuthFailure.invalidCredentials());

  @override
  Stream<AppUser?> authStateChanges() => controller.stream;

  @override
  Future<Either<AuthFailure, AppUser>> signIn(String e, String p) async =>
      signInResult;

  @override
  Future<Either<AuthFailure, AppUser>> signUp(String e, String p, String n) async =>
      right(AppUser(id: 'new', email: e, displayName: n));

  @override
  Future<void> signOut() async => controller.add(null);

  @override
  AppUser? getSignedInUser() => null;

  @override
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail(String e) async =>
      right(unit);
}

void main() {
  const user = AppUser(id: 'u1', email: 'a@b.co', displayName: 'Ali');

  test('starts in AuthInitial and follows the first auth event', () async {
    final repo = _FakeAuthRepo();
    final n = AuthNotifier(repo);
    expect(n.state, isA<AuthInitial>());
    repo.controller.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(n.state, isA<AuthUnauthenticated>());
    repo.controller.add(user);
    await Future<void>.delayed(Duration.zero);
    expect(n.state, isA<AuthAuthenticated>());
  });

  test('wrong password keeps a failure until the user edits', () async {
    final repo = _FakeAuthRepo();
    final n = AuthNotifier(repo);
    repo.controller.add(null);
    await Future<void>.delayed(Duration.zero);

    await n.signIn('a@b.co', 'nope');
    expect(n.state, isA<AuthFailureState>());
    expect((n.state as AuthFailureState).failure.code,
        AuthFailureCode.invalidCredentials);

    // A late "signed out" event must not wipe the visible error.
    repo.controller.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(n.state, isA<AuthFailureState>());

    n.clearError();
    expect(n.state, isA<AuthUnauthenticated>());
  });

  test('sign-up keeps the display name from its own result', () async {
    final repo = _FakeAuthRepo();
    final n = AuthNotifier(repo);
    await n.signUp('x@y.co', 'password1', 'Sara Khan');
    // Firebase then emits the user without a display name yet.
    repo.controller
        .add(const AppUser(id: 'new', email: 'x@y.co', displayName: 'x'));
    await Future<void>.delayed(Duration.zero);
    expect((n.state as AuthAuthenticated).user.displayName, 'Sara Khan');
  });

  test('maps Firebase codes to typed failures', () {
    expect(AuthFailure.fromCode('invalid-credential').code,
        AuthFailureCode.invalidCredentials);
    expect(AuthFailure.fromCode('network-request-failed').code,
        AuthFailureCode.network);
    expect(AuthFailure.fromCode('too-many-requests').code,
        AuthFailureCode.tooManyRequests);
    expect(AuthFailure.fromCode('something-new').code, AuthFailureCode.unknown);
  });
}
