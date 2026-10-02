// lib/domain/core/failures.dart

/// Domain-layer failures.
library;

// ─── Base ─────────────────────────────────────────────────────────────────────

abstract class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType(message: $message)';
}

// ─── AuthFailure ─────────────────────────────────────────────────────────────

/// Machine-readable reason for an [AuthFailure]; pages switch on this
/// instead of matching message text.
enum AuthFailureCode {
  invalidCredentials,
  userNotFound,
  invalidEmail,
  emailInUse,
  weakPassword,
  userDisabled,
  network,
  tooManyRequests,
  unknown,
}

class AuthFailure extends Failure {
  const AuthFailure._(super.message, [this.code = AuthFailureCode.unknown]);

  final AuthFailureCode code;

  /// Maps a Firebase Auth error code (e.g. `invalid-credential`).
  factory AuthFailure.fromCode(String code) => switch (code) {
        'invalid-credential' ||
        'wrong-password' ||
        'invalid-login-credentials' =>
          AuthFailure.invalidCredentials(),
        'user-not-found' => AuthFailure.userNotFound(),
        'invalid-email' => AuthFailure.invalidEmail(),
        'email-already-in-use' => AuthFailure.emailAlreadyInUse(),
        'weak-password' => AuthFailure.weakPassword(),
        'user-disabled' => AuthFailure.userDisabled(),
        'network-request-failed' => AuthFailure.network(),
        'too-many-requests' => AuthFailure.tooManyRequests(),
        _ => AuthFailure.serverError(),
      };

  /// Email or password is wrong (Firebase no longer says which).
  factory AuthFailure.invalidCredentials() => const AuthFailure._(
      'Email or password is incorrect.', AuthFailureCode.invalidCredentials);

  /// Kept for older callers; same as [AuthFailure.invalidCredentials].
  factory AuthFailure.wrongPassword() => AuthFailure.invalidCredentials();

  /// The email address is not a valid format.
  factory AuthFailure.invalidEmail() => const AuthFailure._(
      'Please enter a valid email address.', AuthFailureCode.invalidEmail);

  /// No account found for this email address.
  factory AuthFailure.userNotFound() => const AuthFailure._(
      'No account found for this email address.',
      AuthFailureCode.userNotFound);

  /// A sign-up was attempted with an email that already has an account.
  factory AuthFailure.emailAlreadyInUse() => const AuthFailure._(
      'This email is already registered. Try signing in instead.',
      AuthFailureCode.emailInUse);

  /// The password does not meet minimum security requirements.
  factory AuthFailure.weakPassword() => const AuthFailure._(
      'That password is too weak. Use at least 8 characters.',
      AuthFailureCode.weakPassword);

  factory AuthFailure.userDisabled() => const AuthFailure._(
      'This account has been disabled.', AuthFailureCode.userDisabled);

  factory AuthFailure.network() => const AuthFailure._(
      "You're offline. Check your connection and try again.",
      AuthFailureCode.network);

  factory AuthFailure.tooManyRequests() => const AuthFailure._(
      'Too many attempts. Wait a minute and try again.',
      AuthFailureCode.tooManyRequests);

  /// A generic server error occurred.
  factory AuthFailure.serverError() =>
      const AuthFailure._('Something went wrong. Please try again.');

  /// An unexpected error occurred.
  factory AuthFailure.unexpected() =>
      const AuthFailure._('An unexpected error occurred.');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailure &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => Object.hash(code, message);
}

// ─── ChatFailure ─────────────────────────────────────────────────────────────

class ChatFailure extends Failure {
  const ChatFailure._(super.message);

  factory ChatFailure.serverError() =>
      const ChatFailure._('The AI service encountered an error. Please retry.');

  factory ChatFailure.messageNotSent() => const ChatFailure._(
      'Your message could not be sent. Check your connection.');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

// ─── StudyFailure ─────────────────────────────────────────────────────────────

class StudyFailure extends Failure {
  const StudyFailure._(super.message);

  factory StudyFailure.serverError() =>
      const StudyFailure._('A server error occurred. Please try again.');

  factory StudyFailure.unexpected() =>
      const StudyFailure._('An unexpected error occurred.');

  factory StudyFailure.geminiError(String message) =>
      StudyFailure._('Gemini error: $message');

  factory StudyFailure.firestoreError(String message) =>
      StudyFailure._('Firestore error: $message');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

// ─── AiFailure ───────────────────────────────────────────────────────────────

/// Typed failures from the AI service. Never show raw exception text to the
/// user; use [AiFailureX.message] instead.
enum AiFailure { offline, timeout, rateLimited, unauthorized, badResponse, unknown }

extension AiFailureX on AiFailure {
  String get message => switch (this) {
        AiFailure.offline =>
          "You're offline. Check your connection and try again.",
        AiFailure.timeout => 'The tutor is taking too long. Please try again.',
        AiFailure.rateLimited =>
          'The free AI model is busy right now. Wait a few seconds and retry.',
        AiFailure.unauthorized => "The AI service isn't configured correctly.",
        AiFailure.badResponse =>
          'That answer came back garbled. Please try again.',
        AiFailure.unknown => 'Something went wrong. Please try again.',
      };

  /// Whether retrying the same request can reasonably succeed.
  bool get isRetriable => this != AiFailure.unauthorized;
}
