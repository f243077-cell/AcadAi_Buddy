import 'dart:async';

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
import 'package:study_ai_app/domain/study/entities/chat_session.dart';
import 'package:study_ai_app/domain/study/entities/quiz_result.dart';
import 'package:study_ai_app/presentation/core/theme.dart';
import 'package:study_ai_app/presentation/pages/sign_in/sign_in_page.dart';
import 'package:study_ai_app/presentation/pages/study/home/home_page.dart';

class _Auth implements IAuthRepository {
  int signIns = 0;

  @override
  Stream<AppUser?> authStateChanges() => const Stream.empty();
  @override
  Future<Either<AuthFailure, AppUser>> signIn(String e, String p) async {
    signIns++;
    return left(AuthFailure.invalidCredentials());
  }

  @override
  Future<Either<AuthFailure, AppUser>> signUp(String e, String p, String n) async =>
      left(AuthFailure.serverError());
  @override
  Future<void> signOut() async {}
  @override
  AppUser? getSignedInUser() => null;
  @override
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail(String e) async =>
      right(unit);
}

const _user = AppUser(id: 'u1', email: 'sara@nu.edu.pk', displayName: 'Sara Khan');

Widget _app(Widget child, List<Override> overrides, {double scale = 1.0}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child,
          ),
        ),
      ),
    );

void _phone(WidgetTester t) {
  t.view.physicalSize = const Size(360, 720);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void main() {
  setUpAll(() => AppFonts.useGoogleFonts = false);

  testWidgets('sign in validates fields, then shows the failure inline and keeps the email',
      (t) async {
    _phone(t);
    final repo = _Auth();
    await t.pumpWidget(_app(const SignInPage(), [
      authNotifierProvider.overrideWith((ref) => AuthNotifier(repo)),
    ]));

    await t.tap(find.text('Sign in'));
    await t.pump();
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(repo.signIns, 0);

    await t.enterText(find.byType(TextField).at(0), 'not-an-email');
    await t.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);

    await t.enterText(find.byType(TextField).at(0), 'sara@nu.edu.pk');
    await t.enterText(find.byType(TextField).at(1), 'wrong');
    await t.tap(find.text('Sign in'));
    await t.pumpAndSettle();
    expect(repo.signIns, 1);
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(find.text('sara@nu.edu.pk'), findsOneWidget);

    // Editing clears the banner.
    await t.enterText(find.byType(TextField).at(1), 'wrong2');
    await t.pump();
    expect(find.text('Email or password is incorrect.'), findsNothing);
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('sign in has no overflow at ${scale}x', (t) async {
      _phone(t);
      await t.pumpWidget(_app(
        const SignInPage(),
        [authNotifierProvider.overrideWith((ref) => AuthNotifier(_Auth()))],
        scale: scale,
      ));
      await t.pump();
      expect(t.takeException(), isNull);
    });

    testWidgets('home with data has no overflow at ${scale}x', (t) async {
      _phone(t);
      final now = DateTime.now();
      final chats = [
        for (var i = 0; i < 4; i++)
          ChatSession(
            id: 'c$i',
            ownerId: 'u1',
            subject: i.isEven ? 'Data Structures & Algorithms' : 'Probability & Statistics',
            title: 'What is the base case in recursion and why does it matter $i',
            lastMessage: 'The base case stops the recursion. Without it the '
                'function keeps calling itself until the stack overflows.',
            createdAt: now,
            updatedAt: now.subtract(Duration(hours: i * 20)),
          ),
      ];
      final results = [
        QuizResult(
            id: 'r1',
            subject: 'Design & Analysis of Algorithms',
            score: 8,
            total: 10,
            createdAt: now),
      ];
      await t.pumpWidget(_app(
        const HomePage(),
        [
          currentUserProvider.overrideWithValue(_user),
          chatHistoryProvider.overrideWith((ref) => Stream.value(chats)),
          quizResultsProvider.overrideWith((ref) => Stream.value(results)),
        ],
        scale: scale,
      ));
      await t.pump();
      await t.pump();
      expect(t.takeException(), isNull);
      expect(find.text('Sara'), findsOneWidget);
      expect(find.text('CONTINUE STUDYING'), findsOneWidget);
      // Scroll the whole page so every block is laid out and checked.
      await t.scrollUntilVisible(find.text('80%'), 200);
      await t.scrollUntilVisible(find.text('RECENT CHATS'), 200);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('home without data hides progress and shows the first-session card',
      (t) async {
    _phone(t);
    await t.pumpWidget(_app(const HomePage(), [
      currentUserProvider.overrideWithValue(_user),
      chatHistoryProvider.overrideWith((ref) => Stream.value(const [])),
      quizResultsProvider.overrideWith((ref) => Stream.value(const [])),
    ]));
    await t.pump();
    await t.pump();
    expect(find.text('Start your first session'), findsOneWidget);
    expect(find.text('PROGRESS'), findsNothing);
  });
}
