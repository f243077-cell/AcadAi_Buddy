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

class AuthFailure extends Failure {
  const AuthFailure._(super.message);

  /// The email address is not a valid format.
  factory AuthFailure.invalidEmail() =>
      const AuthFailure._('The email address is badly formatted.');

  /// The password does not match the one stored for this account.
  factory AuthFailure.wrongPassword() =>
      const AuthFailure._('The password is incorrect.');

  /// No account found for this email address.
  factory AuthFailure.userNotFound() =>
      const AuthFailure._('No account found for this email address.');

  /// A sign-up was attempted with an email that already has an account.
  factory AuthFailure.emailAlreadyInUse() =>
      const AuthFailure._('An account already exists for that email address.');

  /// The password does not meet minimum security requirements.
  factory AuthFailure.weakPassword() => const AuthFailure._(
      'The password is too weak. Use at least 6 characters.');

  /// A generic server / network error occurred.
  factory AuthFailure.serverError() =>
      const AuthFailure._('A server error occurred. Please try again.');

  /// An unexpected error occurred.
  factory AuthFailure.unexpected() =>
      const AuthFailure._('An unexpected error occurred.');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
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
