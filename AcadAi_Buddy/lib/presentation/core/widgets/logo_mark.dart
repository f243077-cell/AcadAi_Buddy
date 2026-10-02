import 'package:flutter/material.dart';

import '../theme.dart';

/// Placeholder logo: a gold rounded square with a navy school icon.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'AcadAI Buddy logo',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius:
              size >= 64 ? AppRadius.cardAll : AppRadius.inputAll,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.school_rounded,
          color: AppColors.onAccent,
          size: size * 0.58,
        ),
      ),
    );
  }
}
