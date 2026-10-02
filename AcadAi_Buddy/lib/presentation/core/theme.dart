// lib/presentation/core/theme.dart
//
// Design tokens (colour, type, spacing, radius, motion) and the app theme.
// Every colour, size and radius in the UI comes from this file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Colour ───────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF14243A);
  static const Color surfaceAlt = Color(0xFF1B2F49);
  static const Color border = Color(0xFF2C4260);
  static const Color borderStrong = Color(0xFF5A7391);

  static const Color accent = Color(0xFFF4C430);
  static const Color accentPressed = Color(0xFFD9AC1F);
  static const Color onAccent = Color(0xFF0D1B2A);

  static const Color textPrimary = Color(0xFFEEF2F7);
  static const Color textSecondary = Color(0xFFA9B8C9);
  static const Color textMuted = Color(0xFF8497AD);

  static const Color success = Color(0xFF4ADE9A);
  static const Color error = Color(0xFFFF7A8A);
  static const Color warning = Color(0xFFFFB547);
  static const Color info = Color(0xFF6CB4FF);

  // Legacy names kept as aliases so older imports keep compiling.
  static const Color accentDim = accentPressed;
  static const Color textHint = textMuted;
  static const Color divider = border;
  static const Color userBubble = surfaceAlt;
  static const Color modelBubble = surface;

  /// A token at reduced opacity, for tinted fills (badges, selections).
  static Color tint(Color c, [double alpha = 0.12]) =>
      c.withValues(alpha: alpha);
}

// ─── Spacing (4 pt grid) ──────────────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  static const double screen = 20;
  static const double chatScreen = 16;
  static const double section = 24;
  static const double card = 16;

  /// Minimum touch target.
  static const double touch = 48;
}

// ─── Shape ────────────────────────────────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double input = 12;
  static const double button = 12;
  static const double card = 16;
  static const double sheet = 24;
  static const double pill = 999;

  static const BorderRadius inputAll = BorderRadius.all(Radius.circular(input));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius sheetAll = BorderRadius.all(Radius.circular(sheet));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

// ─── Motion ───────────────────────────────────────────────────────────────────
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Curve curve = Curves.easeOutCubic;

  /// [d], or zero when the platform asks to reduce motion.
  static Duration of(BuildContext context, Duration d) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;
}

// ─── Typography ───────────────────────────────────────────────────────────────
class AppFonts {
  AppFonts._();

  /// Set to false in tests so no font is fetched over the network.
  static bool useGoogleFonts = true;

  static TextStyle sans(double size, double height, FontWeight weight,
      {double letterSpacing = 0}) {
    final base = TextStyle(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: AppColors.textPrimary,
    );
    return useGoogleFonts ? GoogleFonts.inter(textStyle: base) : base;
  }

  static TextStyle serif(double size, double height, FontWeight weight) {
    final base = TextStyle(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      color: AppColors.textPrimary,
    );
    return useGoogleFonts ? GoogleFonts.sourceSerif4(textStyle: base) : base;
  }

  static TextStyle mono(double size, double height) {
    final base = TextStyle(
      fontSize: size,
      height: height / size,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      fontFamilyFallback: const ['monospace'],
    );
    return useGoogleFonts ? GoogleFonts.jetBrainsMono(textStyle: base) : base;
  }
}

/// Type scale (Section 4.2). Never go below 11 sp.
class AppText {
  AppText._();

  static final TextStyle display = AppFonts.serif(32, 40, FontWeight.w600);
  static final TextStyle titleL = AppFonts.serif(24, 32, FontWeight.w600);
  static final TextStyle titleM = AppFonts.sans(20, 28, FontWeight.w600);
  static final TextStyle titleS = AppFonts.sans(16, 24, FontWeight.w600);
  static final TextStyle bodyL = AppFonts.sans(16, 24, FontWeight.w400);
  static final TextStyle bodyM = AppFonts.sans(14, 20, FontWeight.w400);
  static final TextStyle label = AppFonts.sans(13, 16, FontWeight.w600);
  static final TextStyle caption = AppFonts.sans(12, 16, FontWeight.w400);
  static final TextStyle overline =
      AppFonts.sans(11, 16, FontWeight.w600, letterSpacing: 0.8);
  static final TextStyle code = AppFonts.mono(13, 20);

  /// Quiz question text (Inter 18/28, 600).
  static final TextStyle question = AppFonts.sans(18, 28, FontWeight.w600);
}

// ─── Theme ────────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    primaryContainer: AppColors.surfaceAlt,
    onPrimaryContainer: AppColors.accent,
    secondary: AppColors.info,
    onSecondary: AppColors.onAccent,
    tertiary: AppColors.success,
    onTertiary: AppColors.onAccent,
    error: AppColors.error,
    onError: AppColors.onAccent,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.surface,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.surfaceAlt,
    surfaceContainerHighest: AppColors.surfaceAlt,
    outline: AppColors.borderStrong,
    outlineVariant: AppColors.border,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.background,
    inversePrimary: AppColors.accentPressed,
    shadow: Colors.black,
    scrim: Colors.black,
  );

  final textTheme = TextTheme(
    displaySmall: AppText.display,
    headlineSmall: AppText.titleL,
    titleLarge: AppText.titleM,
    titleMedium: AppText.titleS,
    titleSmall: AppText.label,
    bodyLarge: AppText.bodyL,
    bodyMedium: AppText.bodyM,
    bodySmall: AppText.caption.copyWith(color: AppColors.textSecondary),
    labelLarge: AppText.titleS,
    labelMedium: AppText.label,
    labelSmall: AppText.overline,
  );

  OutlineInputBorder inputBorder(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: AppRadius.inputAll,
        borderSide: BorderSide(color: c, width: w),
      );

  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
  );
  const buttonSize = Size(AppSpacing.touch, 52);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.titleM,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 24),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(AppSpacing.touch, AppSpacing.touch),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
      hintStyle: AppText.bodyM.copyWith(color: AppColors.textMuted),
      labelStyle: AppText.bodyM.copyWith(color: AppColors.textSecondary),
      floatingLabelStyle: AppText.label.copyWith(color: AppColors.accent),
      helperStyle: AppText.caption.copyWith(color: AppColors.textMuted),
      errorStyle: AppText.caption.copyWith(color: AppColors.error),
      prefixIconColor: AppColors.textMuted,
      suffixIconColor: AppColors.textMuted,
      border: inputBorder(AppColors.borderStrong),
      enabledBorder: inputBorder(AppColors.borderStrong),
      focusedBorder: inputBorder(AppColors.accent, 1.5),
      errorBorder: inputBorder(AppColors.error),
      focusedErrorBorder: inputBorder(AppColors.error, 1.5),
      disabledBorder: inputBorder(AppColors.border),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        disabledBackgroundColor: AppColors.surfaceAlt,
        disabledForegroundColor: AppColors.textMuted,
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: AppText.titleS,
        elevation: 0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        disabledBackgroundColor: AppColors.surfaceAlt,
        disabledForegroundColor: AppColors.textMuted,
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: AppText.titleS,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        minimumSize: buttonSize,
        shape: buttonShape,
        side: const BorderSide(color: AppColors.borderStrong),
        textStyle: AppText.titleS,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        minimumSize: const Size(AppSpacing.touch, AppSpacing.touch),
        shape: buttonShape,
        textStyle: AppText.label,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.onAccent,
      extendedTextStyle: AppText.titleS,
      shape: buttonShape,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.tint(AppColors.accent, 0.16),
      side: const BorderSide(color: AppColors.border),
      shape: const StadiumBorder(),
      labelStyle: AppText.label.copyWith(color: AppColors.textPrimary),
      secondaryLabelStyle: AppText.label.copyWith(color: AppColors.accent),
      checkmarkColor: AppColors.accent,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textSecondary,
        selectedBackgroundColor: AppColors.tint(AppColors.accent, 0.16),
        selectedForegroundColor: AppColors.accent,
        side: const BorderSide(color: AppColors.borderStrong),
        minimumSize: const Size(AppSpacing.touch, AppSpacing.touch),
        textStyle: AppText.label,
        shape: buttonShape,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.tint(AppColors.accent, 0.16),
      height: 68,
      elevation: 0,
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.textMuted,
          )),
      labelTextStyle: WidgetStateProperty.resolveWith((states) =>
          AppText.label.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.textPrimary
                : AppColors.textMuted,
          )),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: AppColors.surface,
      showDragHandle: true,
      dragHandleColor: AppColors.borderStrong,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetAll),
      titleTextStyle: AppText.titleM,
      contentTextStyle:
          AppText.bodyM.copyWith(color: AppColors.textSecondary),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceAlt,
      contentTextStyle: AppText.bodyM,
      actionTextColor: AppColors.accent,
      elevation: 6,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputAll),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surfaceAlt,
      surfaceTintColor: Colors.transparent,
      textStyle: AppText.bodyM,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputAll),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textPrimary,
      titleTextStyle: AppText.titleS,
      subtitleTextStyle:
          AppText.bodyM.copyWith(color: AppColors.textSecondary),
      minVerticalPadding: AppSpacing.md,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
      linearTrackColor: AppColors.border,
      circularTrackColor: AppColors.border,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionColor: AppColors.tint(AppColors.accent, 0.35),
      selectionHandleColor: AppColors.accent,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppRadius.inputAll,
      ),
      textStyle: AppText.caption,
    ),
  );
}

/// Kept for existing imports.
final ThemeData appTheme = buildAppTheme();
