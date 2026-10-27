import 'dart:async';
import 'dart:io' show FileSystemException;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../services/selfie_photo_verifier.dart';

class SelfieVerificationScreen extends StatefulWidget {
  const SelfieVerificationScreen({super.key});

  @override
  State<SelfieVerificationScreen> createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends State<SelfieVerificationScreen> {
  static const _poses = SelfiePose.values;

  final _verifier = SelfiePhotoVerifier();
  CameraController? _camera;
  Timer? _verificationTimer;
  Uint8List? _profileSelfie;
  int _step = 0;
  bool _initializing = true;
  bool _checking = false;
  String? _error;

  SelfiePose get _currentPose => _poses[_step];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCameras = cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.front)
          .toList();
      if (frontCameras.isEmpty) {
        throw CameraException(
          'NoFrontCamera',
          'This device does not have a front camera.',
        );
      }

      final camera = CameraController(
        frontCameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _camera = camera;
      await camera.initialize();
      if (mounted) {
        setState(() => _initializing = false);
        unawaited(_capturePose());
        _verificationTimer = Timer.periodic(
          const Duration(milliseconds: 1200),
          (_) => unawaited(_capturePose()),
        );
      }
    } on CameraException catch (error) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = error.description ?? 'Could not start the front camera.';
        });
      }
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = error.message ?? 'Camera permission is required.';
        });
      }
    }
  }

  Future<void> _capturePose() async {
    final camera = _camera;
    if (_checking || camera == null || !camera.value.isInitialized) return;

    setState(() {
      _checking = true;
      _error = null;
    });

    try {
      final photo = await camera.takePicture();
      final verificationError = await _verifier.verify(
        photo.path,
        _currentPose,
      );
      if (verificationError != null) {
        if (mounted) setState(() => _error = verificationError);
        return;
      }

      if (_step == 0) {
        _profileSelfie = await photo.readAsBytes();
      }

      if (_step == _poses.length - 1) {
        if (mounted) {
          setState(() => _step = _poses.length);
          _verificationTimer?.cancel();
          await Future<void>.delayed(const Duration(milliseconds: 650));
          if (mounted) Navigator.of(context).pop(_profileSelfie);
        }
        return;
      }

      if (mounted) setState(() => _step++);
    } on CameraException catch (error) {
      if (mounted) {
        setState(
          () => _error = error.description ?? 'Could not capture image.',
        );
      }
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() => _error = error.message ?? 'Could not verify this step.');
      }
    } on FileSystemException {
      if (mounted) {
        setState(() => _error = 'Could not read the selfie. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    final camera = _camera;
    if (camera != null) unawaited(camera.dispose());
    unawaited(_verifier.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedSteps = _step;
    final progress = completedSteps / _poses.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selfie verification'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 9,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${(progress * 100).round()}%'),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _step == _poses.length
                    ? 'Face-direction check complete!'
                    : _instruction(_currentPose),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                _step == _poses.length
                    ? 'All ${_poses.length} steps passed'
                    : 'Step ${_step + 1} of ${_poses.length} · Keep one face in the frame',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.subtext),
              ),
              const SizedBox(height: 16),
              Expanded(child: _cameraContent()),
              const SizedBox(height: 14),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 10),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_initializing || _checking)
                    const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      _initializing
                          ? 'Starting camera...'
                          : _checking
                          ? 'Checking automatically...'
                          : 'Hold this pose; the camera checks automatically.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'No button needed. Completing all steps shows 100%. This camera check cannot guarantee protection from every spoofing attempt.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.subtext, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cameraContent() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      return Center(
        child: Text(
          _error ?? 'Front camera is unavailable.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(camera),
              IgnorePointer(
                child: Center(
                  child: Container(
                    width: 230,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(120),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _instruction(SelfiePose pose) => switch (pose) {
    SelfiePose.center => 'Look straight at the camera',
    SelfiePose.left => 'Slowly turn your head to the left',
    SelfiePose.right => 'Slowly turn your head to the right',
    SelfiePose.up => 'Slowly look up',
    SelfiePose.down => 'Slowly look down',
    SelfiePose.blinkStart => 'Keep both eyes open',
    SelfiePose.blinkClosed => 'Now close both eyes',
    SelfiePose.blinkOpen => 'Open both eyes again',
  };
}
