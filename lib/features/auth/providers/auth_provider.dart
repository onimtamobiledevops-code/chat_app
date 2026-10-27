import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/auth_repository.dart';

/// The signed-in user, or `null` when signed out.
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() => ref.watch(authRepositoryProvider).currentUser();

  /// Throws [AuthException] when the mobile number is not registered.
  /// Leaves [state] untouched; the PIN step does the actual sign-in.
  Future<void> checkMobileNumber(String mobileNumber) =>
      ref.read(authRepositoryProvider).checkMobileNumber(mobileNumber);

  /// Throws [AuthException] when the mobile number or PIN is wrong.
  /// The caller shows the error,
  /// so a failed attempt never kicks the app out of its current state.
  Future<void> signInWithMobile(String mobileNumber, String pin) async {
    final user = await ref
        .read(authRepositoryProvider)
        .signInWithMobile(mobileNumber, pin);
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
