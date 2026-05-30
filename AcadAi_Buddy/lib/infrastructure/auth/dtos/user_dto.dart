import 'package:study_ai_app/domain/auth/entities/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDto {
  final String id;
  final String email;
  final String displayName;

  const UserDto({
    required this.id,
    required this.email,
    required this.displayName,
  });

  factory UserDto.fromFirebase(User user) {
    return UserDto(
      id: user.uid,
      email: user.email ?? '',
      displayName:
          user.displayName ?? user.email?.split('@').first ?? 'Student',
    );
  }

  AppUser toDomain() {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
    };
  }

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
    );
  }
}
