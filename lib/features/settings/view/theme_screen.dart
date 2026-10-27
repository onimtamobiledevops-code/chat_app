import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_mode_provider.dart';

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPalette = ref.watch(appThemePaletteProvider);
    final selectedWallpaper = ref.watch(chatWallpaperProvider);
    final fontSize = ref.watch(messageFontSizeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Theme')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'Choose your theme',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 10.0;
                final cardWidth = (constraints.maxWidth - spacing * 3) / 4;
                final customPalette = selectedPalette.id == 'custom'
                    ? selectedPalette
                    : AppThemePalette.custom(const Color(0xFF178F9B));
                final palettes = [...AppThemePalette.values, customPalette];

                return Wrap(
                  spacing: spacing,
                  runSpacing: 12,
                  children: [
                    for (final palette in palettes)
                      SizedBox(
                        width: cardWidth,
                        child: _PaletteTile(
                          palette: palette,
                          selected: selectedPalette.id == palette.id,
                          onTap: () async {
                            if (palette.id == 'custom') {
                              final color = await _chooseCustomColor(context);
                              if (color != null) {
                                ref
                                    .read(appThemePaletteProvider.notifier)
                                    .setPalette(AppThemePalette.custom(color));
                              }
                              return;
                            }
                            ref
                                .read(appThemePaletteProvider.notifier)
                                .setPalette(palette);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Chat wallpaper',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  selectedWallpaper.name,
                  style: TextStyle(color: colorScheme.primary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ChatWallpaper.values.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == ChatWallpaper.values.length) {
                    final customWallpaper = selectedWallpaper.id == 'custom'
                        ? selectedWallpaper
                        : ChatWallpaper.defaults;
                    return _WallpaperTile(
                      wallpaper: customWallpaper,
                      selected: selectedWallpaper.id == 'custom',
                      isGalleryPicker: true,
                      onTap: () => _pickGalleryWallpaper(context, ref),
                    );
                  }
                  final wallpaper = ChatWallpaper.values[index];
                  return _WallpaperTile(
                    wallpaper: wallpaper,
                    selected: selectedWallpaper.id == wallpaper.id,
                    onTap: () => ref
                        .read(chatWallpaperProvider.notifier)
                        .setWallpaper(wallpaper),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            _SettingsPanel(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    value: isDark,
                    onChanged: (enabled) => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(
                          enabled ? ThemeMode.dark : ThemeMode.light,
                        ),
                    secondary: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Dark mode'),
                    subtitle: const Text('Change the app appearance'),
                    activeTrackColor: colorScheme.primary,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    leading: const Icon(Icons.phone_android_rounded),
                    title: const Text('Use device theme'),
                    subtitle: Text(
                      themeMode == ThemeMode.system
                          ? 'Following your device settings'
                          : 'Switch back to automatic appearance',
                    ),
                    trailing: themeMode == ThemeMode.system
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: colorScheme.primary,
                          )
                        : null,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Font size',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${fontSize.round()} px',
                  style: TextStyle(color: context.subtext, fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.text_fields_rounded, size: 18),
                Expanded(
                  child: Slider(
                    min: 13,
                    max: 22,
                    divisions: 9,
                    value: fontSize,
                    activeColor: colorScheme.primary,
                    onChanged: ref
                        .read(messageFontSizeProvider.notifier)
                        .setFontSize,
                  ),
                ),
                const Icon(Icons.text_fields_rounded, size: 25),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Color?> _chooseCustomColor(BuildContext context) {
    const colors = [
      Color(0xFF178F9B),
      Color(0xFFDB4777),
      Color(0xFF6650C8),
      Color(0xFF23834C),
      Color(0xFFC16622),
      Color(0xFF3369C6),
      Color(0xFF4F5968),
      Color(0xFFAD3F3F),
    ];

    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose a color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final color in colors)
              InkWell(
                onTap: () => Navigator.of(context).pop(color),
                borderRadius: BorderRadius.circular(24),
                child: CircleAvatar(
                  backgroundColor: color,
                  child: const Icon(Icons.check, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickGalleryWallpaper(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 88,
      );
      if (image == null || !context.mounted) return;

      final bytes = await image.readAsBytes();
      if (!context.mounted) return;
      ref
          .read(chatWallpaperProvider.notifier)
          .setWallpaper(ChatWallpaper.customImage(bytes));
    } on PlatformException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Could not open your photo gallery.'),
        ),
      );
    }
  }
}

class _PaletteTile extends StatelessWidget {
  final AppThemePalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteTile({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outlineVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: palette.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    palette.primary,
                    palette.accent,
                    palette.darkBackground,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: selected ? 2 : 1),
              ),
              child: Center(
                child: selected
                    ? const Icon(Icons.check_circle, color: Colors.white)
                    : const Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              palette.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WallpaperTile extends StatelessWidget {
  final ChatWallpaper wallpaper;
  final bool selected;
  final VoidCallback onTap;
  final bool isGalleryPicker;

  const _WallpaperTile({
    required this.wallpaper,
    required this.selected,
    required this.onTap,
    this.isGalleryPicker = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: isGalleryPicker ? 'Choose from gallery' : wallpaper.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 64,
          decoration: BoxDecoration(
            gradient: wallpaper.imageBytes == null ? wallpaper.gradient : null,
            image: wallpaper.imageBytes == null
                ? null
                : DecorationImage(
                    image: MemoryImage(wallpaper.imageBytes!),
                    fit: BoxFit.cover,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              if (isGalleryPicker)
                const Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                )
              else
                const Positioned(
                  right: 8,
                  bottom: 22,
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
              if (selected)
                const Positioned(
                  top: 5,
                  right: 5,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: Text(
                  isGalleryPicker
                      ? wallpaper.id == 'custom'
                            ? 'My photo'
                            : 'Gallery'
                      : wallpaper.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final Widget child;

  const _SettingsPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
