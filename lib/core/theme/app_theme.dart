import 'package:flutter/material.dart';

class AppColors {
  static const accent = Color(0xFF16A34A);

  static const lightSurface = Colors.white;
  static const lightIncoming = Colors.white;
  static const lightText = Color(0xFF1A1C29);
  static const lightSubtext = Color(0xFF8A8FA3);

  static const darkText = Color(0xFFF1F2F6);
  static const darkSubtext = Color(0xFF8A8FA3);

  static const avatarPalette = [
    Color(0xFFF97316),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFEAB308),
    Color(0xFF3B82F6),
    Color(0xFFEF4444),
  ];
}

class AppThemePalette {
  final String id;
  final String name;
  final Color primary;
  final Color accent;
  final Color lightBackground;
  final Color darkBackground;
  final Color darkSurface;
  final Color darkIncoming;

  const AppThemePalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.accent,
    required this.lightBackground,
    required this.darkBackground,
    required this.darkSurface,
    required this.darkIncoming,
  });

  static const green = AppThemePalette(
    id: 'green',
    name: 'ChatWBee Green',
    primary: Color(0xFF168343),
    accent: Color(0xFF5AE37A),
    lightBackground: Color(0xFFF3FAF4),
    darkBackground: Color(0xFF0D1711),
    darkSurface: Color(0xFF14231A),
    darkIncoming: Color(0xFF1B2E22),
  );

  static const ocean = AppThemePalette(
    id: 'ocean',
    name: 'Ocean Blue',
    primary: Color(0xFF2169B2),
    accent: Color(0xFF69B8F5),
    lightBackground: Color(0xFFF2F7FC),
    darkBackground: Color(0xFF0D141C),
    darkSurface: Color(0xFF151F2B),
    darkIncoming: Color(0xFF1D2B3B),
  );

  static const violet = AppThemePalette(
    id: 'violet',
    name: 'Violet',
    primary: Color(0xFF7048B8),
    accent: Color(0xFFB497F0),
    lightBackground: Color(0xFFF7F4FB),
    darkBackground: Color(0xFF15111C),
    darkSurface: Color(0xFF20192B),
    darkIncoming: Color(0xFF2A2138),
  );

  static const sunset = AppThemePalette(
    id: 'sunset',
    name: 'Sunset',
    primary: Color(0xFFB85B18),
    accent: Color(0xFFFFB45E),
    lightBackground: Color(0xFFFCF6F0),
    darkBackground: Color(0xFF1C140E),
    darkSurface: Color(0xFF291D14),
    darkIncoming: Color(0xFF38271A),
  );

  static const forest = AppThemePalette(
    id: 'forest',
    name: 'Forest',
    primary: Color(0xFF26745C),
    accent: Color(0xFF78D4A7),
    lightBackground: Color(0xFFF2F8F5),
    darkBackground: Color(0xFF101A16),
    darkSurface: Color(0xFF192720),
    darkIncoming: Color(0xFF21352A),
  );

  static const midnight = AppThemePalette(
    id: 'midnight',
    name: 'Midnight',
    primary: Color(0xFF5265A9),
    accent: Color(0xFF9DACF5),
    lightBackground: Color(0xFFF3F5FA),
    darkBackground: Color(0xFF10131D),
    darkSurface: Color(0xFF191E2B),
    darkIncoming: Color(0xFF242B3C),
  );

  static const lavender = AppThemePalette(
    id: 'lavender',
    name: 'Lavender',
    primary: Color(0xFF8059B8),
    accent: Color(0xFFC0A4F0),
    lightBackground: Color(0xFFF8F5FC),
    darkBackground: Color(0xFF17121E),
    darkSurface: Color(0xFF221B2D),
    darkIncoming: Color(0xFF30253E),
  );

  static const rose = AppThemePalette(
    id: 'rose',
    name: 'Rose',
    primary: Color(0xFFB54B74),
    accent: Color(0xFFF09BB8),
    lightBackground: Color(0xFFFCF4F7),
    darkBackground: Color(0xFF1C1117),
    darkSurface: Color(0xFF291A22),
    darkIncoming: Color(0xFF38232E),
  );

  static const values = [
    green,
    ocean,
    forest,
    sunset,
    midnight,
    lavender,
    violet,
    rose,
  ];

  static AppThemePalette custom(Color primary) => AppThemePalette(
        id: 'custom',
        name: 'Custom',
        primary: primary,
        accent: Color.lerp(primary, Colors.white, 0.42)!,
        lightBackground: Color.lerp(Colors.white, primary, 0.045)!,
        darkBackground: Color.lerp(const Color(0xFF101014), primary, 0.18)!,
        darkSurface: Color.lerp(const Color(0xFF19191E), primary, 0.2)!,
        darkIncoming: Color.lerp(const Color(0xFF24242A), primary, 0.22)!,
      );
}

class AppTheme {
  static ThemeData light([AppThemePalette palette = AppThemePalette.green]) =>
      _build(
        brightness: Brightness.light,
        bg: palette.lightBackground,
        surface: AppColors.lightSurface,
        incoming: AppColors.lightIncoming,
        text: AppColors.lightText,
        subtext: AppColors.lightSubtext,
        palette: palette,
      );

  static ThemeData dark([AppThemePalette palette = AppThemePalette.green]) =>
      _build(
        brightness: Brightness.dark,
        bg: palette.darkBackground,
        surface: palette.darkSurface,
        incoming: palette.darkIncoming,
        text: AppColors.darkText,
        subtext: AppColors.darkSubtext,
        palette: palette,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color incoming,
    required Color text,
    required Color subtext,
    required AppThemePalette palette,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: brightness,
      primary: palette.primary,
      secondary: palette.accent,
      surface: surface,
      surfaceContainerLow: incoming,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: text,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: text),
        bodySmall: TextStyle(fontSize: 12, color: subtext),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: subtext),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: palette.accent.withValues(alpha: 0.24),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get subtext => isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get incomingBubble => Theme.of(this).colorScheme.surfaceContainerLow;
}
