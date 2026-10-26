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
  Future<User> signInWithMobile(String mobileNumber);
  Future<User> signUp(SignUpRequest request);
  Future<void> signOut();
}

class DummyAuthRepository implements AuthRepository {
  static const demoMobileNumber = '+94771234567';

  User? _user;
  final Map<String, User> _accounts = {};

  @override
  Future<User?> currentUser() async => _user;

  @override
  Future<User> signInWithMobile(String mobileNumber) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final normalizedMobile = mobileNumber.trim();
    if (normalizedMobile == demoMobileNumber) {
      return _user = const User(
        id: 'me',
        name: 'Demo User',
        isOnline: true,
        mobileNumber: demoMobileNumber,
      );
    }

    final account = _accounts[normalizedMobile];
    if (account == null) {
      throw const AuthException('No account found for this mobile number.');
    }
    return _user = account;
  }

  @override
  Future<User> signUp(SignUpRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final mobileNumber = request.mobileNumber.trim();
    if (mobileNumber == demoMobileNumber ||
        _accounts.containsKey(mobileNumber)) {
      throw const AuthException(
        'An account with this mobile number already exists.',
      );
    }

    final membershipNumber = request.membershipNumber.trim();
    if (_accounts.values.any(
      (account) => account.membershipNumber == membershipNumber,
    )) {
      throw const AuthException(
        'An account with this membership number already exists.',
      );
    }

    final user = User(
      id: 'member-${DateTime.now().microsecondsSinceEpoch}',
      name: request.name.trim(),
      isOnline: true,
      membershipNumber: membershipNumber,
      mobileNumber: mobileNumber,
      remarks: request.remarks?.trim(),
      photoBytes: request.photoBytes,
    );
    _accounts[mobileNumber] = user;
    return _user = user;
  }

  @override
  Future<void> signOut() async => _user = null;
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => DummyAuthRepository(),
);
