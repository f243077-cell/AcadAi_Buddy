// lib/domain/auth/entities/app_user.dart

/// Domain entity representing an authenticated user.
///
/// Pure Dart — no Firebase or external imports.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  /// The unique identifier for this user (maps to Firebase UID).
  final String id;

  /// The user's email address.
  final String email;

  /// The user's chosen display name.
  final String displayName;

  /// Returns a copy of this user with the given fields replaced.
  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName;

  @override
  int get hashCode => Object.hash(id, email, displayName);

  @override
  // FIX: was split across two lines with a space → '$d             isplayName'
  String toString() =>
      'AppUser(id: $id, email: $email, displayName: $displayName)';
}
