import '../application/auth/auth_state.dart';

const kSplashPath = '/';
const kSignInPath = '/sign-in';
const kSignUpPath = '/sign-up';
const kHomePath = '/home';

/// Where to send the user for [location] given the auth state, or null to
/// stay. Pure so it can be unit-tested.
///
/// Only [AuthInitial] counts as "booting". [AuthLoading] (a sign-in or
/// sign-up in progress) never moves the user off the auth pages.
String? authRedirect({
  required AuthState auth,
  required String location,
  bool splashDone = true,
}) {
  final onSplash = location == kSplashPath;
  final onAuthPage = location == kSignInPath || location == kSignUpPath;

  if (auth is AuthInitial) return onSplash ? null : kSplashPath;
  if (onSplash && !splashDone) return null;

  if (auth is AuthAuthenticated) {
    return (onSplash || onAuthPage) ? kHomePath : null;
  }
  // Unauthenticated, failure, or loading from a sign-in/up form.
  return onAuthPage ? null : kSignInPath;
}
