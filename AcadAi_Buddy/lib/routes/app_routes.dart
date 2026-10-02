import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/auth/auth_notifier.dart';
import '../presentation/pages/debug/widget_gallery_page.dart';
import '../presentation/pages/shell/app_shell.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/sign_in/sign_in_page.dart';
import '../presentation/pages/sign_up/sign_up_page.dart';
import '../presentation/pages/study/home/home_page.dart';
import '../presentation/pages/study/chat/chat_page.dart';
import '../presentation/pages/study/quiz/quiz_page.dart';
import '../presentation/pages/study/summarize/summarize_page.dart';
import '../presentation/pages/study/tutor/tutor_page.dart';
import 'auth_redirect.dart';

/// Flips to true once the splash has been visible for its minimum time.
final splashMinElapsedProvider = StateProvider<bool>((ref) => false);

/// Created once. Auth changes re-run [authRedirect] through
/// [GoRouter.refreshListenable] instead of rebuilding the router.
final appRouterProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final refresh = ValueNotifier<int>(0);
  ref.listen(authNotifierProvider, (_, __) => refresh.value++);
  ref.listen(splashMinElapsedProvider, (_, __) => refresh.value++);

  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: kSplashPath,
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      auth: ref.read(authNotifierProvider),
      location: state.matchedLocation,
      splashDone: ref.read(splashMinElapsedProvider),
    ),
    routes: [
      GoRoute(
        path: kSplashPath,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: kSignInPath,
        name: 'sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: kSignUpPath,
        name: 'sign-up',
        builder: (context, state) => const SignUpPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: kHomePath,
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tutor',
              name: 'tutor',
              builder: (context, state) => const TutorPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/quiz',
              name: 'quiz',
              builder: (context, state) => const QuizPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/summarize',
              name: 'summarize',
              builder: (context, state) => const SummarizePage(),
            ),
          ]),
        ],
      ),
      // Pushed over the shell (no bottom bar).
      GoRoute(
        path: '/chat/:chatId',
        name: 'chat',
        parentNavigatorKey: rootKey,
        builder: (context, state) =>
            ChatPage(chatId: state.pathParameters['chatId']!),
      ),
      if (kDebugMode)
        GoRoute(
          path: '/gallery',
          parentNavigatorKey: rootKey,
          builder: (context, state) => const WidgetGalleryPage(),
        ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
