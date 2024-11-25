import 'package:camera/camera.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_scanner/src/mlkit_extension.dart';
import 'camera_overlay.dart';

class MRZCameraView extends StatefulWidget {
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;
  final bool showOverlay;

  const MRZCameraView({
    super.key,
    required this.onImage,
    this.initialDirection = CameraLensDirection.back,
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
        children: <Widget>[
          CameraAwesomeBuilder.custom(
              imageAnalysisConfig: AnalysisConfig(maxFramesPerSecond: 60),
              onImageForAnalysis: (img) async => _processAwesomeImage(img),
              saveConfig: SaveConfig.photo(),
              onMediaCaptureEvent: (event) {
                switch (event.status) {
                  default:
                    debugPrint('Unknown event: $event');
                }
              },
              builder: (CameraState state, Preview preview) => state.when(
                onPhotoMode: (photoCameraState) => Container(),
              )
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
