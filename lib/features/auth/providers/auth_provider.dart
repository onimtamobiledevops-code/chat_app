import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/auth_repository.dart';

/// The signed-in user, or `null` when signed out.
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() => ref.watch(authRepositoryProvider).currentUser();

  /// Throws [AuthException] when the mobile number is not registered.
  /// The caller shows the error,
  /// so a failed attempt never kicks the app out of its current state.
  Future<void> signInWithMobile(String mobileNumber) async {
    final user = await ref
        .read(authRepositoryProvider)
        .signInWithMobile(mobileNumber);
    state = AsyncData(user);
  }

  Future<void> signUp(SignUpRequest request) async {
    final user = await ref.read(authRepositoryProvider).signUp(request);
    state = AsyncData(user);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
