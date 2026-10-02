import 'package:flutter_test/flutter_test.dart';
import 'package:study_ai_app/application/auth/auth_state.dart';
import 'package:study_ai_app/domain/auth/entities/app_user.dart';
import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/routes/auth_redirect.dart';

void main() {
  const user = AppUser(id: 'u1', email: 'a@b.co', displayName: 'Ali');
  final states = <String, AuthState>{
    'initial': const AuthInitial(),
    'loading': const AuthLoading(),
    'authenticated': const AuthAuthenticated(user),
    'unauthenticated': const AuthUnauthenticated(),
    'failure': AuthFailureState(AuthFailure.invalidCredentials()),
  };
  const paths = ['/', '/sign-in', '/sign-up', '/home', '/tutor', '/chat/x'];

  // Expected redirect for each state on each path (null = stay).
  final expected = <String, List<String?>>{
    'initial': [null, '/', '/', '/', '/', '/'],
    'loading': ['/sign-in', null, null, '/sign-in', '/sign-in', '/sign-in'],
    'authenticated': ['/home', '/home', '/home', null, null, null],
    'unauthenticated': ['/sign-in', null, null, '/sign-in', '/sign-in', '/sign-in'],
    'failure': ['/sign-in', null, null, '/sign-in', '/sign-in', '/sign-in'],
  };

  for (final entry in states.entries) {
    for (var i = 0; i < paths.length; i++) {
      test('${entry.key} on ${paths[i]}', () {
        expect(
          authRedirect(auth: entry.value, location: paths[i]),
          expected[entry.key]![i],
        );
      });
    }
  }

  test('splash stays until its minimum time has passed', () {
    expect(
      authRedirect(
          auth: const AuthAuthenticated(user), location: '/', splashDone: false),
      isNull,
    );
    expect(
      authRedirect(
          auth: const AuthUnauthenticated(), location: '/', splashDone: false),
      isNull,
    );
  });
}
