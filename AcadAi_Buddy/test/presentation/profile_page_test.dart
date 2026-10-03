import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_ai_app/application/auth/auth_notifier.dart';
import 'package:study_ai_app/application/chat/chat_history.dart';
import 'package:study_ai_app/application/quiz/quiz_notifier.dart';
import 'package:study_ai_app/domain/auth/entities/app_user.dart';
import 'package:study_ai_app/domain/auth/repositories/i_auth_repositories.dart';
import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/domain/study/entities/quiz_result.dart';
import 'package:study_ai_app/presentation/core/app_info.dart';
import 'package:study_ai_app/presentation/core/theme.dart';
import 'package:study_ai_app/presentation/pages/profile/profile_page.dart';

const _user = AppUser(id: 'u1', email: 'sara@nu.edu.pk', displayName: 'Sara Khan');

class _Auth implements IAuthRepository {
  final names = <String>[];
  @override
  Stream<AppUser?> authStateChanges() => Stream.value(_user);
  @override
  Future<Either<AuthFailure, AppUser>> signIn(String e, String p) async => right(_user);
  @override
  Future<Either<AuthFailure, AppUser>> signUp(String e, String p, String n) async =>
      right(_user);
  @override
  Future<void> signOut() async {}
  @override
  AppUser? getSignedInUser() => _user;
  @override
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail(String e) async =>
      right(unit);
  @override
  Future<Either<AuthFailure, AppUser>> updateDisplayName(String n) async {
    names.add(n);
    return right(_user.copyWith(displayName: n));
  }
}

void main() {
  setUpAll(() => AppFonts.useGoogleFonts = false);

  testWidgets('shows account details and real stats, no developer tools',
      (t) async {
    final repo = _Auth();
    await t.pumpWidget(ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => AuthNotifier(repo)),
        chatHistoryProvider.overrideWith((ref) => Stream.value(const [])),
        quizResultsProvider.overrideWith((ref) => Stream.value([
              QuizResult(id: 'r', subject: 'DSA', score: 7, total: 10, createdAt: DateTime(2026)),
            ])),
      ],
      child: MaterialApp(theme: buildAppTheme(), home: const ProfilePage()),
    ));
    await t.pump();
    await t.pump();

    expect(find.text('Sara Khan'), findsWidgets);
    expect(find.text('sara@nu.edu.pk'), findsWidgets);
    expect(find.text('70%'), findsOneWidget);
    expect(find.textContaining('gallery', findRichText: true), findsNothing);
    expect(find.textContaining('Debug'), findsNothing);

    // Edit name.
    await t.tap(find.text('Name'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'Sara Ahmed');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(repo.names, ['Sara Ahmed']);
    expect(find.text('Sara Ahmed'), findsWidgets);
    expect(find.text('Name updated'), findsOneWidget);

    // Sign out asks for confirmation.
    await t.scrollUntilVisible(find.text('Sign out'), 200);
    await t.tap(find.text('Sign out'));
    await t.pumpAndSettle();
    expect(find.text('Sign out?'), findsOneWidget);
  });

  test('About version matches pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*([0-9.]+)', multiLine: true)
        .firstMatch(pubspec)!
        .group(1);
    expect(kAppVersion, version);
  });
}
