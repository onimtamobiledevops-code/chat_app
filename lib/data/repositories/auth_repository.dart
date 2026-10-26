import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

/// The contract the UI depends on. Add a `FirebaseAuthRepository` (etc.)
/// that implements this and swap it in [authRepositoryProvider].
abstract class AuthRepository {
  Future<User?> currentUser();
  Future<User> signIn(String email, String password);
  Future<void> signOut();
}

class DummyAuthRepository implements AuthRepository {
  static const demoEmail = 'demo@gmail.com';
  static const demoPassword = '123456';

  User? _user;

  @override
  Future<User?> currentUser() async => _user;

  @override
  Future<User> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.trim().toLowerCase() != demoEmail || password != demoPassword) {
      throw const AuthException('Incorrect email or password.');
    }
    return _user = const User(id: 'me', name: 'Demo User', isOnline: true);
  }

  @override
  Future<void> signOut() async => _user = null;
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => DummyAuthRepository(),
);
