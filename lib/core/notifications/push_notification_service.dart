import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks for notification permission and registers this device with FCM.
/// Once there is a backend, send the registration ID to it so it can push
/// messages to this device.
class PushNotificationService {
  final FirebaseMessaging _messaging;

  PushNotificationService(this._messaging);

  /// Returns this device's FCM registration ID, or `null` when the user
  /// denies permission.
  Future<String?> init() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }

    // iOS hides notifications while the app is open unless told otherwise.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen before registering so the ID it reports is not missed.
    final registrationId = _messaging.onRegistered.first;
    await _messaging.register();
    final id = await registrationId;
    debugPrint('FCM registration ID: $id');
    return id;
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(FirebaseMessaging.instance),
);

/// This device's FCM registration ID. Read it once the user signs in so the
/// permission prompt does not show on the login screen.
final fcmRegistrationIdProvider = FutureProvider<String?>(
  (ref) => ref.watch(pushNotificationServiceProvider).init(),
);
