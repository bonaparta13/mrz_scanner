import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

extension MLKitUtils on AnalysisImage {
  InputImage toInputImage() {
    final planeData =
        when(nv21: (img) => img.planes, bgra8888: (img) => img.planes)?.map(
      (plane) {
        return plane.bytesPerRow;
      },
    ).first;

    return when(nv21: (image) {
      return InputImage.fromBytes(
        bytes: image.bytes,
        metadata: InputImageMetadata(
          rotation: inputImageRotation,
          format: InputImageFormat.nv21,
          bytesPerRow: planeData!,
          size: image.size,
        ),
      );
    }, bgra8888: (image) {
      final inputImageData = InputImageMetadata(
        size: size,
        rotation: inputImageRotation,
        format: inputImageFormat,
        bytesPerRow: planeData!,
      );

      return InputImage.fromBytes(
        bytes: image.bytes,
        metadata: inputImageData,
      );
    })!;
  }

  InputImageRotation get inputImageRotation =>
      InputImageRotation.values.byName(rotation.name);

  InputImageFormat get inputImageFormat {
    switch (format) {
      case InputAnalysisImageFormat.bgra8888:
        return InputImageFormat.bgra8888;
      case InputAnalysisImageFormat.nv21:
        return InputImageFormat.nv21;
      default:
        return InputImageFormat.yuv420;
    }
  }
}
