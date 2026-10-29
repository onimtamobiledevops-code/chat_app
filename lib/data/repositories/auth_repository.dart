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

  /// Throws [AuthException] when no account uses [mobileNumber].
  Future<void> checkMobileNumber(String mobileNumber);
  Future<User> signInWithMobile(String mobileNumber, String pin);
  Future<User> signUp(SignUpRequest request);
  Future<void> signOut();
}

class DummyAuthRepository implements AuthRepository {
  static const demoMobileNumber = '+94759888880';

  /// Every dummy account uses this PIN until sign-up lets members pick one.
  static const demoPin = '1234';

  User? _user;
  final Map<String, User> _accounts = {};

  @override
  Future<User?> currentUser() async => _user;

  @override
  Future<void> checkMobileNumber(String mobileNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _accountFor(mobileNumber);
  }

  @override
  Future<User> signInWithMobile(String mobileNumber, String pin) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final account = _accountFor(mobileNumber);
    if (pin != demoPin) {
      throw const AuthException('Incorrect PIN. Please try again.');
    }
    return _user = account;
  }

  User _accountFor(String mobileNumber) {
    final normalizedMobile = mobileNumber.trim();
    if (normalizedMobile == demoMobileNumber) {
      return const User(
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
    return account;
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
