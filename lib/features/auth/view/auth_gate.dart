import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../chats/view/home_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

/// Shows [LoginScreen] or [HomeScreen] depending on the auth state.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return auth.when(
      data: (user) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: user == null
            ? const LoginScreen(key: ValueKey('login'))
            : const HomeScreen(key: ValueKey('home')),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const LoginScreen(),
    );
  }
}
