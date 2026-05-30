import 'package:uuid/uuid.dart';

// ─── EmailAddress ─────────────────────────────────────────────────────────────

/// A validated email address value object.
///
/// Construction via [EmailAddress.new] always produces a valid-or-invalid
/// instance. Check [isValid] before using [value], or use [valueOrNull].
class EmailAddress {
  const EmailAddress._(this._value, this._isValid);

  factory EmailAddress(String input) {
    final trimmed = input.trim().toLowerCase();
    final valid = _emailRegex.hasMatch(trimmed);
    return EmailAddress._(trimmed, valid);
  }

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  final String _value;
  final bool _isValid;

  /// Whether this email address passes format validation.
  bool get isValid => _isValid;

  /// The raw (trimmed, lowercased) input string regardless of validity.
  String get value => _value;

  /// Returns the email string if valid, or `null` otherwise.
  String? get valueOrNull => _isValid ? _value : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailAddress &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'EmailAddress(value: $_value, isValid: $_isValid)';
}

// ─── Password ─────────────────────────────────────────────────────────────────

/// A validated password value object.
///
/// Minimum length: **6 characters**.
/// The raw value is stored in plain text in memory only — never persist it.
class Password {
  const Password._(this._value, this._isValid);

  factory Password(String input) {
    final valid = input.length >= _minLength;
    return Password._(input, valid);
  }

  static const int _minLength = 6;

  final String _value;
  final bool _isValid;

  /// Whether this password meets the minimum length requirement.
  bool get isValid => _isValid;

  /// The raw password string regardless of validity.
  ///
  /// ⚠️ Never log or persist this value.
  String get value => _value;

  /// Returns the password string if valid, or `null` otherwise.
  String? get valueOrNull => _isValid ? _value : null;

  /// Human-readable reason why the password is invalid, or `null` if valid.
  String? get validationMessage =>
      _isValid ? null : 'Password must be at least $_minLength characters.';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Password &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  // Intentionally no toString() that exposes _value.
  @override
  String toString() => 'Password(isValid: $_isValid)';
}

// ─── UniqueId ─────────────────────────────────────────────────────────────────

/// A UUID-based unique identifier value object.
///
/// ```dart
/// // Generate a new random ID:
/// final id = UniqueId();
///
/// // Wrap an existing ID string (e.g. from Firestore):
/// final id = UniqueId.fromString(docSnapshot.id);
/// ```
class UniqueId {
  const UniqueId._(this.value);

  /// Creates a new random UUID v4 identifier.
  factory UniqueId() {
    const uuid = Uuid();
    return UniqueId._(uuid.v4());
  }

  /// Wraps an existing identifier string.
  ///
  /// Does **not** validate the format — pass whatever the storage layer gives you.
  factory UniqueId.fromString(String id) {
    assert(id.isNotEmpty, 'UniqueId.fromString: id must not be empty');
    return UniqueId._(id);
  }

  /// The underlying string representation of the ID.
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniqueId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'UniqueId($value)';
}
