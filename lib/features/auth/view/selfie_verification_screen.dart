import 'package:camera/camera.dart' show ResolutionPreset;
import 'package:flutter/material.dart';
import 'package:flutter_face_liveness/flutter_face_liveness.dart';

import '../../../core/theme/app_theme.dart';

/// Runs a liveness check with `flutter_face_liveness` and pops with the
/// most front-facing frame as JPEG bytes for the profile photo.
class SelfieVerificationScreen extends StatefulWidget {
  const SelfieVerificationScreen({super.key});

  @override
  State<SelfieVerificationScreen> createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends State<SelfieVerificationScreen> {
  static const _actions = [
    LivenessAction.turnLeft,
    LivenessAction.turnRight,
    LivenessAction.lookUp,
    LivenessAction.lookDown,
    LivenessAction.blink,
  ];

  String? _failure;

  Future<void> _onSuccess(LivenessResult result) async {
    final selfie = result.bestFrontalImageBytes;
    if (selfie == null) {
      _onFailed('Could not capture your selfie.');
      return;
    }
    // Let the library's success tick show before closing.
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (mounted) Navigator.of(context).pop(selfie);
  }

  void _onFailed(String reason) {
    if (mounted) setState(() => _failure = reason);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selfie verification'),
        centerTitle: true,
      ),
      body: _failure == null
          ? FlutterFaceLiveness(
              actions: _actions,
              config: LivenessConfig(
                cameraResolution: ResolutionPreset.medium,
                enableBestFrontalCapture: true,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              ),
              onSuccess: _onSuccess,
              onFailed: _onFailed,
            )
          : _failureView(_failure!),
    );
  }

  Widget _failureView(String reason) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Verification failed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$reason\nUse good lighting and keep only your face in the frame.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.subtext),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => setState(() => _failure = null),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
