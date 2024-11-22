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
  static Uint8List? convertToNV21(CameraImage image) {
    try {
      final planeY = image.planes[0].bytes;
      final planeU = image.planes[1].bytes;
      final planeV = image.planes[2].bytes;

      final width = image.width;
      final height = image.height;
      final nv21Size = (width * height * 3) >> 1;

      final nv21Bytes = Uint8List(nv21Size);
      nv21Bytes.setRange(0, width * height, planeY);
      
      int uvIndex = width * height;
      for (int i = 0; i < planeV.length; i++) {
        if (uvIndex >= nv21Size) break;
        nv21Bytes[uvIndex] = planeV[i];
        uvIndex++;

        if (uvIndex >= nv21Size) break;
        nv21Bytes[uvIndex] = planeU[i];
        uvIndex++;
      }

      return nv21Bytes;
    } catch (e) {
      if (kDebugMode) {
        print("Error converting to NV21: $e");
      }
      return null;
    }
  }

  /// Converts a [CameraImage] to BGRA8888 format (iOS).
  /// 
  /// BGRA8888 is a pixel format where each pixel is represented by 4 bytes
  /// (Blue, Green, Red, Alpha). This format is required for MLKit on iOS.
  /// 
  /// Returns a [Uint8List] representing the image in BGRA8888 format, or null if the conversion fails.
  static Uint8List? convertToBGRA8888(CameraImage image) {
    try {
      return image.planes[0].bytes;
    } catch (e) {
      if (kDebugMode) {
        print("Error converting to BGRA8888: $e");
      }
      return null;
    }
  }
}