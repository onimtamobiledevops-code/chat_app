import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode themeMode) => state = themeMode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class AppThemePaletteNotifier extends Notifier<AppThemePalette> {
  @override
  AppThemePalette build() => AppThemePalette.green;

  void setPalette(AppThemePalette palette) => state = palette;
}

final appThemePaletteProvider =
    NotifierProvider<AppThemePaletteNotifier, AppThemePalette>(
      AppThemePaletteNotifier.new,
    );

class ChatWallpaper {
  final String id;
  final String name;
  final Color first;
  final Color second;
  final Color? third;
  final Uint8List? imageBytes;

  const ChatWallpaper({
    required this.id,
    required this.name,
    required this.first,
    required this.second,
    this.third,
    this.imageBytes,
  });

  static const defaults = ChatWallpaper(
    id: 'default',
    name: 'Default',
    first: Color(0xFF10201A),
    second: Color(0xFF1C382A),
  );

  static const mist = ChatWallpaper(
    id: 'mist',
    name: 'Morning',
    first: Color(0xFFDFEBE4),
    second: Color(0xFFF4F7F2),
    third: Color(0xFFE3EFE8),
  );

  static const ocean = ChatWallpaper(
    id: 'ocean',
    name: 'Ocean',
    first: Color(0xFF0D4260),
    second: Color(0xFF276A86),
    third: Color(0xFF17445F),
  );

  static const dusk = ChatWallpaper(
    id: 'dusk',
    name: 'Dusk',
    first: Color(0xFF39274A),
    second: Color(0xFF80516E),
    third: Color(0xFF49344F),
  );

  static const forest = ChatWallpaper(
    id: 'forest',
    name: 'Forest',
    first: Color(0xFF163D2E),
    second: Color(0xFF39805B),
    third: Color(0xFF1D553D),
  );

  static const values = [defaults, mist, ocean, dusk, forest];

  factory ChatWallpaper.customImage(Uint8List imageBytes) => ChatWallpaper(
    id: 'custom',
    name: 'My photo',
    first: defaults.first,
    second: defaults.second,
    imageBytes: imageBytes,
  );

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [first, ?third, second],
  );

  BoxDecoration get decoration => BoxDecoration(
    gradient: imageBytes == null ? gradient : null,
    image: imageBytes == null
        ? null
        : DecorationImage(image: MemoryImage(imageBytes!), fit: BoxFit.cover),
  );
}

class ChatWallpaperNotifier extends Notifier<ChatWallpaper> {
  @override
  ChatWallpaper build() => ChatWallpaper.defaults;

  void setWallpaper(ChatWallpaper wallpaper) => state = wallpaper;
}

final chatWallpaperProvider =
    NotifierProvider<ChatWallpaperNotifier, ChatWallpaper>(
      ChatWallpaperNotifier.new,
    );

class MessageFontSizeNotifier extends Notifier<double> {
  @override
  double build() => 15;

  void setFontSize(double fontSize) => state = fontSize;
}

final messageFontSizeProvider =
    NotifierProvider<MessageFontSizeNotifier, double>(
      MessageFontSizeNotifier.new,
    );
