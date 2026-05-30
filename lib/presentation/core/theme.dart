import 'package:flutter/material.dart';

// ─── Colour Palette ───────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0D1B2A); // deep navy
  static const Color surface = Color(0xFF162236); // slightly lighter navy
  static const Color surfaceAlt = Color(0xFF1E2F45); // card surface
  static const Color accent = Color(0xFFF4C430); // satin gold
  static const Color accentDim = Color(0xFFB8921F); // muted gold
  static const Color onAccent = Color(0xFF0D1B2A); // text on gold buttons
  static const Color textPrimary = Color(0xFFE8DCC8); // warm parchment white
  static const Color textSecondary = Color(0xFF8FA3B8); // muted steel blue
  static const Color textHint = Color(0xFF4A6580); // dim hint
  static const Color divider = Color(0xFF243447); // subtle separator
  static const Color error = Color(0xFFCF6679); // muted rose error
  static const Color success = Color(0xFF4CAF7D); // muted sage green
  static const Color userBubble = Color(0xFF1A3A5C); // chat bubble (user)
  static const Color modelBubble = Color(0xFF162236); // chat bubble (model)
}

// ─── Typography ───────────────────────────────────────────────────────────────
// Uses fonts that ship with Flutter's default Material config.
// Swap to a Google Font (e.g. "Playfair Display" + "Source Serif 4") by adding
// the google_fonts package and replacing the fontFamily strings below.
const String _displayFont = 'Georgia'; // serif display — scholarly feel
const String _bodyFont = 'Georgia'; // consistent serif throughout

TextTheme _buildTextTheme() {
  return const TextTheme(
    // Display — used for large hero text
    displayLarge: TextStyle(
      fontFamily: _displayFont,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      color: AppColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: _displayFont,
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: AppColors.textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: _displayFont,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    // Headline — page titles, section headers
    headlineLarge: TextStyle(
      fontFamily: _displayFont,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: _displayFont,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: _displayFont,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    // Title — card titles, dialog headers
    titleLarge: TextStyle(
      fontFamily: _displayFont,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.10,
      color: AppColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.10,
      color: AppColors.textSecondary,
    ),

    // Body — main content
    bodyLarge: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: AppColors.textSecondary,
    ),

    // Label — buttons, chips, captions
    labelLarge: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
      color: AppColors.onAccent,
    ),
    labelMedium: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      color: AppColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: AppColors.textHint,
    ),
  );
}

// ─── Component Themes ─────────────────────────────────────────────────────────

CardThemeData _buildCardTheme() {
  return CardThemeData(
    color: AppColors.surfaceAlt,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.divider, width: 1),
    ),
    clipBehavior: Clip.antiAlias,
  );
}

ElevatedButtonThemeData _buildElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.onAccent,
      disabledBackgroundColor: AppColors.accentDim.withAlpha(102),
      disabledForegroundColor: AppColors.onAccent.withAlpha(102),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
  );
}

OutlinedButtonThemeData _buildOutlinedButtonTheme() {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.accent,
      side: const BorderSide(color: AppColors.accent, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    ),
  );
}

TextButtonThemeData _buildTextButtonTheme() {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.accent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    ),
  );
}

InputDecorationTheme _buildInputDecorationTheme() {
  const borderRadius = BorderRadius.all(Radius.circular(10));
  const borderSide = BorderSide(color: AppColors.divider, width: 1.2);
  const focusedBorder = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(color: AppColors.accent, width: 1.8),
  );
  const errorBorder = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(color: AppColors.error, width: 1.5),
  );

  return InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: const TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      color: AppColors.textHint,
    ),
    labelStyle: const TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
    floatingLabelStyle: const TextStyle(
      fontFamily: _bodyFont,
      fontSize: 12,
      color: AppColors.accent,
      fontWeight: FontWeight.w600,
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: borderSide,
    ),
    focusedBorder: focusedBorder,
    errorBorder: errorBorder,
    focusedErrorBorder: errorBorder,
    disabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: borderSide.copyWith(
        color: AppColors.divider.withAlpha(102),
      ),
    ),
    errorStyle: const TextStyle(
      fontFamily: _bodyFont,
      fontSize: 11,
      color: AppColors.error,
    ),
    prefixIconColor: AppColors.textSecondary,
    suffixIconColor: AppColors.textSecondary,
  );
}

AppBarTheme _buildAppBarTheme() {
  return const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: _displayFont,
      fontSize: 19,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      color: AppColors.textPrimary,
    ),
    iconTheme: IconThemeData(color: AppColors.textSecondary, size: 22),
    actionsIconTheme: IconThemeData(color: AppColors.accent, size: 22),
  );
}

BottomNavigationBarThemeData _buildBottomNavTheme() {
  return const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.accent,
    unselectedItemColor: AppColors.textHint,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 11,
      fontWeight: FontWeight.w400,
    ),
  );
}

SnackBarThemeData _buildSnackBarTheme() {
  return SnackBarThemeData(
    backgroundColor: AppColors.surfaceAlt,
    contentTextStyle: const TextStyle(
      fontFamily: _bodyFont,
      fontSize: 13,
      color: AppColors.textPrimary,
    ),
    actionTextColor: AppColors.accent,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: AppColors.divider),
    ),
    elevation: 4,
  );
}

DialogThemeData _buildDialogTheme() {
  return DialogThemeData(
    backgroundColor: AppColors.surfaceAlt,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.divider, width: 1),
    ),
    titleTextStyle: const TextStyle(
      fontFamily: _displayFont,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    contentTextStyle: const TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      height: 1.5,
      color: AppColors.textSecondary,
    ),
  );
}

ChipThemeData _buildChipTheme() {
  return ChipThemeData(
    backgroundColor: AppColors.surfaceAlt,
    selectedColor: AppColors.accent.withAlpha(51),
    disabledColor: AppColors.surface,
    labelStyle: const TextStyle(
      fontFamily: _bodyFont,
      fontSize: 12,
      color: AppColors.textPrimary,
    ),
    secondaryLabelStyle: const TextStyle(
      fontFamily: _bodyFont,
      fontSize: 12,
      color: AppColors.accent,
    ),
    side: const BorderSide(color: AppColors.divider),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  );
}

DividerThemeData _buildDividerTheme() {
  return const DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  );
}

// ─── Root Theme ───────────────────────────────────────────────────────────────

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.dark(
    brightness: Brightness.dark,
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    primaryContainer: AppColors.accentDim.withAlpha((0.25 * 255).round()),
    onPrimaryContainer: AppColors.accent,
    secondary: AppColors.textSecondary,
    onSecondary: AppColors.background,
    secondaryContainer: AppColors.surfaceAlt,
    onSecondaryContainer: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceAlt,
    error: AppColors.error,
    onError: AppColors.background,
    outline: AppColors.divider,
    outlineVariant: AppColors.textHint,
  ),
  textTheme: _buildTextTheme(),
  cardTheme: _buildCardTheme(),
  elevatedButtonTheme: _buildElevatedButtonTheme(),
  outlinedButtonTheme: _buildOutlinedButtonTheme(),
  textButtonTheme: _buildTextButtonTheme(),
  inputDecorationTheme: _buildInputDecorationTheme(),
  appBarTheme: _buildAppBarTheme(),
  bottomNavigationBarTheme: _buildBottomNavTheme(),
  snackBarTheme: _buildSnackBarTheme(),
  dialogTheme: _buildDialogTheme(),
  chipTheme: _buildChipTheme(),
  dividerTheme: _buildDividerTheme(),
  iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.accent,
    linearTrackColor: AppColors.divider,
    circularTrackColor: AppColors.divider,
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.accent;
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.onAccent),
    side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.accent;
      return AppColors.textSecondary;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.onAccent;
      return AppColors.textHint;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.accent;
      return AppColors.divider;
    }),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.accent,
    foregroundColor: AppColors.onAccent,
    elevation: 4,
    shape: CircleBorder(),
  ),
  listTileTheme: const ListTileThemeData(
    tileColor: Colors.transparent,
    iconColor: AppColors.textSecondary,
    textColor: AppColors.textPrimary,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  ),
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.divider),
    ),
    textStyle: const TextStyle(
      fontFamily: _bodyFont,
      fontSize: 12,
      color: AppColors.textPrimary,
    ),
  ),
);
