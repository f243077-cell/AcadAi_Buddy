import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/auth/auth_notifier.dart';
import '../application/auth/auth_state.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/sign_in/sign_in_page.dart';
import '../presentation/pages/sign_up/sign_up_page.dart';
import '../presentation/pages/study/home/home_page.dart';
import '../presentation/pages/study/chat/chat_page.dart';
import '../presentation/pages/study/quiz/quiz_page.dart';
import '../presentation/pages/study/summarize/summarize_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;

      if (authState is AuthInitial || authState is AuthLoading) {
        // Stay on splash while checking auth
        return location == '/' ? null : '/';
      }

      if (authState is AuthAuthenticated) {
        // Authenticated users should not be on auth pages
        if (location == '/' ||
            location == '/sign-in' ||
            location == '/sign-up') {
          return '/home';
        }
        return null;
      }

      if (authState is AuthUnauthenticated || authState is AuthFailureState) {
        // Unauthenticated users can only access auth pages
        if (location == '/sign-in' || location == '/sign-up') {
          return null;
        }
        return '/sign-in';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign-up',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        name: 'chat',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatPage(chatId: chatId);
        },
      ),
      GoRoute(
        path: '/quiz',
        name: 'quiz',
        builder: (context, state) => const QuizPage(),
      ),
      GoRoute(
        path: '/summarize',
        name: 'summarize',
        builder: (context, state) => const SummarizePage(),
      ),
    ],
  );
});
