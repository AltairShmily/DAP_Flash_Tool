import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        surface: AppColors.darkSurface,
        primary: AppColors.darkPrimary,
        onSurface: AppColors.darkOnSurface,
        surfaceContainerHighest: AppColors.darkSurfaceContainer,
      ),
    );
    return _applyShared(base);
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        surface: AppColors.lightSurface,
        primary: AppColors.lightPrimary,
        onSurface: AppColors.lightOnSurface,
        surfaceContainerHighest: AppColors.lightSurfaceContainer,
      ),
    );
    return _applyShared(base);
  }

  static ThemeData _applyShared(ThemeData base) {
    final monoFont = GoogleFonts.jetBrainsMono();
    final uiFont = GoogleFonts.inter();

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        // UI text uses Inter
        bodyLarge: base.textTheme.bodyLarge?.copyWith(fontFamily: uiFont.fontFamily),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(fontFamily: uiFont.fontFamily),
        bodySmall: base.textTheme.bodySmall?.copyWith(fontFamily: uiFont.fontFamily),
        titleLarge: base.textTheme.titleLarge?.copyWith(fontFamily: uiFont.fontFamily),
        titleMedium: base.textTheme.titleMedium?.copyWith(fontFamily: uiFont.fontFamily),
        titleSmall: base.textTheme.titleSmall?.copyWith(fontFamily: uiFont.fontFamily),
        labelLarge: base.textTheme.labelLarge?.copyWith(fontFamily: uiFont.fontFamily),
        labelMedium: base.textTheme.labelMedium?.copyWith(fontFamily: uiFont.fontFamily),
        labelSmall: base.textTheme.labelSmall?.copyWith(fontFamily: uiFont.fontFamily),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      // Provide mono font family as an extension for easy access
      extensions: [_MonoFontFamily(monoFont.fontFamily ?? 'monospace')],
    );
  }

  /// Convenience: get the monospace font family from context.
  static String monoFamily(BuildContext context) {
    return Theme.of(context).extension<_MonoFontFamily>()?.family ?? 'monospace';
  }
}

class _MonoFontFamily extends ThemeExtension<_MonoFontFamily> {
  final String family;
  const _MonoFontFamily(this.family);

  @override
  _MonoFontFamily copyWith({String? family}) => _MonoFontFamily(family ?? this.family);

  @override
  _MonoFontFamily lerp(_MonoFontFamily? other, double t) => this;
}
