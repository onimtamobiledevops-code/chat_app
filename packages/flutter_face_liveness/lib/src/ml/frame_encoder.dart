import 'dart:io' show Platform;
import 'dart:isolate' show Isolate;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:image/image.dart' as img;

import '../identity/face_preprocessor.dart';
import 'face_detector_service.dart' show RawFrameData;

/// Runs [encodeFrameToJpeg] on a background isolate.
///
/// Must stay a top-level function: a closure passed to [Isolate.run] from
/// inside an instance method can capture `this` through the method's shared
/// closure context, and sending the controller (camera, ML Kit, TFLite
/// handles) to another isolate throws — which silently aborted session
/// completion before onSuccess/onFailed could fire.
Future<Uint8List?> encodeFrameToJpegInBackground(RawFrameData frame, {int quality = 85}) {
  return Isolate.run(() => encodeFrameToJpeg(frame, quality: quality));
}

/// Converts a raw camera frame (NV21 on Android, BGRA8888 on iOS) into an
/// upright JPEG — used to expose a human-viewable capture (e.g.
/// [LivenessResult.bestFrontalImageBytes]) from the same raw bytes the
/// identity pipeline already processes internally, without a second camera
/// capture.
///
/// Returns `null` on decode/encode failure rather than throwing — this is a
/// best-effort convenience feature, never critical-path.
Uint8List? encodeFrameToJpeg(RawFrameData frame, {int quality = 85}) {
  try {
    final w = frame.imageWidth;
    final h = frame.imageHeight;
    final image = img.Image(width: w, height: h);

    if (Platform.isIOS) {
      final bytes = frame.imageBytes;
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final p = (y * w + x) * 4;
          image.setPixelRgb(x, y, bytes[p + 2], bytes[p + 1], bytes[p]); // BGRA → RGB
        }
      }
      // iOS frames are already in display-space orientation (ML Kit is
      // handed rotation0deg — see FaceDetectorService._resolveRotation) —
      // no rotation needed here either.
      return img.encodeJpg(image, quality: quality);
    }

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final rgb = FacePreprocessor.yuv2rgbNv21(frame.imageBytes, x, y, w, h);
        image.setPixelRgb(x, y, rgb[0], rgb[1], rgb[2]);
      }
    }

    // Rotate raw sensor-space pixels to upright. sensorOrientation is the
    // clockwise rotation that makes the frame upright (the same value
    // FaceDetectorService hands ML Kit as InputImageRotation), and
    // copyRotate also rotates clockwise, so it is passed through as-is.
    // (Upstream 3.6.0 swapped 90/270 here, which made the capture upside
    // down on Android.)
    final rotateAngle = switch (frame.sensorOrientation) {
      90 || 180 || 270 => frame.sensorOrientation,
      _ => 0,
    };
    final upright = rotateAngle == 0 ? image : img.copyRotate(image, angle: rotateAngle);

    return img.encodeJpg(upright, quality: quality);
  } catch (e) {
    debugPrint('[encodeFrameToJpeg] $e');
    return null;
  }
}
