import 'package:flutter/material.dart';

import '../../../domain/auth/entities/app_user.dart';
import '../theme.dart';

/// Up to two initials from a display name, falling back to the email.
String initialsFor(AppUser user) {
  final words = user.displayName
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isNotEmpty) {
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }
  return user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';
}

String firstNameOf(AppUser user) {
  final name = user.displayName.trim();
  if (name.isEmpty) return 'there';
  return name.split(RegExp(r'\s+')).first;
}

/// Circle with the user's initials.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.user, this.size = 40});

  final AppUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.tint(AppColors.accent, 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent),
      ),
      child: Text(
        initialsFor(user),
        style: (size >= 56 ? AppText.titleM : AppText.label)
            .copyWith(color: AppColors.accent),
      ),
    );
  }
}
