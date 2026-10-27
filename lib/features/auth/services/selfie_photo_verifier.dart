import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum SelfiePose {
  center,
  left,
  right,
  up,
  down,
  blinkStart,
  blinkClosed,
  blinkOpen,
}

class SelfiePhotoVerifier {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<String?> verify(String imagePath, SelfiePose pose) async {
    final faces = await _detector.processImage(
      InputImage.fromFilePath(imagePath),
    );
    return selfiePoseVerificationError(faces, pose);
  }

  Future<void> close() => _detector.close();
}

String? selfiePoseVerificationError(List<Face> faces, SelfiePose pose) {
  if (faces.isEmpty) {
    return 'No face detected. Keep your face inside the camera frame.';
  }
  if (faces.length > 1) {
    return 'Only one person should be visible in the camera frame.';
  }

  final face = faces.single;
  final leftEyeOpen = face.leftEyeOpenProbability;
  final rightEyeOpen = face.rightEyeOpenProbability;
  if (leftEyeOpen == null || rightEyeOpen == null) {
    return 'Could not see your eyes clearly. Try again with better lighting.';
  }

  final yaw = face.headEulerAngleY;
  final pitch = face.headEulerAngleX;
  final roll = face.headEulerAngleZ;
  if (yaw == null || pitch == null || roll == null || roll.abs() > 25) {
    return 'Keep your head upright and try again.';
  }

  if (pose == SelfiePose.blinkClosed) {
    if (yaw.abs() > 18 || pitch.abs() > 18) {
      return 'Keep your face looking straight while blinking.';
    }
    if (leftEyeOpen > 0.25 || rightEyeOpen > 0.25) {
      return 'Close both eyes fully for the blink check.';
    }
    return null;
  }

  if (leftEyeOpen < 0.7 || rightEyeOpen < 0.7) {
    return pose == SelfiePose.blinkStart || pose == SelfiePose.blinkOpen
        ? 'Open both eyes and look straight at the camera.'
        : 'Keep both eyes open while you turn your head.';
  }

  if (pose == SelfiePose.blinkStart || pose == SelfiePose.blinkOpen) {
    if (yaw.abs() > 12 || pitch.abs() > 12) {
      return 'Look straight at the camera before blinking.';
    }
    return null;
  }

  final poseMatches = switch (pose) {
    SelfiePose.center => yaw.abs() < 12 && pitch.abs() < 12,
    SelfiePose.left => yaw >= 18,
    SelfiePose.right => yaw <= -18,
    SelfiePose.up => pitch >= 12,
    SelfiePose.down => pitch <= -12,
    SelfiePose.blinkStart ||
    SelfiePose.blinkClosed ||
    SelfiePose.blinkOpen => false,
  };

  if (!poseMatches) {
    return switch (pose) {
      SelfiePose.center => 'Look straight at the camera.',
      SelfiePose.left => 'Turn your head a little more to your left.',
      SelfiePose.right => 'Turn your head a little more to your right.',
      SelfiePose.up => 'Look up a little more.',
      SelfiePose.down => 'Look down a little more.',
      SelfiePose.blinkStart ||
      SelfiePose.blinkClosed ||
      SelfiePose.blinkOpen => 'Follow the blink instructions.',
    };
  }

  return null;
}
