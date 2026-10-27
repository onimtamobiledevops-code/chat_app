import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/avatar.dart';
import '../../auth/providers/auth_provider.dart';
import 'theme_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final followsDarkTheme =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Row(
            children: [
              const AppLogo(markSize: 42),
              const SizedBox(width: 14),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (user != null)
            _SettingsCard(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Avatar(user: user, size: 52, showOnline: false),
                title: Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('ChatWBee account'),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ),
          const SizedBox(height: 24),
          const _SectionHeading('THEME'),
          const SizedBox(height: 10),
          _SettingsCard(
            child: ListTile(
              leading: Icon(
                Icons.palette_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Theme'),
              subtitle: Text(
                '${ref.watch(appThemePaletteProvider).name} · '
                '${followsDarkTheme ? 'Dark' : 'Light'} mode',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ThemeScreen()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeading('ACCOUNT'),
          const SizedBox(height: 10),
          _SettingsCard(
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Log out',
                style: TextStyle(color: Colors.redAccent),
              ),
              subtitle: const Text('Sign out of this device'),
              onTap: () => _confirmSignOut(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeading('ABOUT'),
          const SizedBox(height: 10),
          _SettingsCard(
            child: const ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('ChatWBee'),
              subtitle: Text('Version 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log back in any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: context.subtext,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
