import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// CameraFormat class handles the conversion of CameraImage
/// to the required formats for MLKit or other image processing libraries:
/// - NV21 (for Android)
/// - BGRA8888 (for iOS)
/// Throws [UnsupportedError] if the platform is neither Android nor iOS.
class CameraFormat {
  /// Converts a [CameraImage] to NV21 format (Android).
  /// 
  /// NV21 is a YUV format where the luminance (Y) is followed by interleaved
  /// chrominance components (VU). This format is required for MLKit on Android.
  /// 
  /// Returns a [Uint8List] representing the image in NV21 format, or null if the conversion fails.
  static Uint8List convertToNV21(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final ySize = width * height;
    final uvExpectedSize = (width ~/ 2) * (height ~/ 2);

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes.sublist(0, uvExpectedSize);
    final vPlane = image.planes[2].bytes.sublist(0, uvExpectedSize);

    final nv21Bytes = Uint8List(ySize + uvExpectedSize * 2);

    // Copy Y plane
    nv21Bytes.setRange(0, ySize, yPlane);

    // Interleave V and U (VU order for NV21)
    int uvIndex = ySize;
    for (int i = 0; i < uvExpectedSize; i++) {
      nv21Bytes[uvIndex++] = vPlane[i];
      nv21Bytes[uvIndex++] = uPlane[i];
    }

    return nv21Bytes;
  }
}