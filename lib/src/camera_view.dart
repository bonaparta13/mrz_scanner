import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_scanner/src/mlkit_extension.dart';
import 'camera_overlay.dart';

class MRZCameraView extends StatefulWidget {
  final Function(InputImage inputImage) onImage;
  final bool autoStart;
  final bool showOverlay;

  const MRZCameraView({
    super.key,
    required this.onImage,
    required this.autoStart,
    required this.showOverlay,
  });

  @override
  MRZCameraViewState createState() => MRZCameraViewState();
}

class MRZCameraViewState extends State<MRZCameraView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      body: widget.showOverlay
          ? MRZCameraOverlay(child: _liveFeedBody())
          : _liveFeedBody(),
    );
  }

  Widget _liveFeedBody() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraAwesomeBuilder.custom(
            imageAnalysisConfig: AnalysisConfig(
              autoStart: widget.autoStart,
            ),
            onImageForAnalysis: (img) async => _processAwesomeImage(img),
            saveConfig: SaveConfig.photo(),
            builder: (CameraState state, Preview preview) => state.when(
              onPhotoMode: (photoCameraState) => SizedBox(key: UniqueKey()),
            ),
          ),
        ],
      ),
    );
  }

  Future _processAwesomeImage(AnalysisImage image) async {
    var inputImage = image.toInputImage();
    widget.onImage(inputImage);
  }
}