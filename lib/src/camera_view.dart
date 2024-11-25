import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_scanner/src/mlkit_extension.dart';
import 'camera_overlay.dart';

class MRZCameraView extends StatefulWidget {
  final Function(InputImage inputImage) onImage;
  final bool showOverlay;

  const MRZCameraView({
    super.key,
    required this.onImage,
    required this.showOverlay,
  });

  @override
  MRZCameraViewState createState() => MRZCameraViewState();
}

class MRZCameraViewState extends State<MRZCameraView> {
  CameraAwesomeBuilder? _awesomeBuilder;

  @override
  void initState() {
    super.initState();
    _prepareCamera();
  }

  @override
  void dispose() {
    _awesomeBuilder = null;
    super.dispose();
  }

  void _prepareCamera() {
    _awesomeBuilder = CameraAwesomeBuilder.custom(
      imageAnalysisConfig: AnalysisConfig(),
      onImageForAnalysis: (img) async => _processAwesomeImage(img),
      saveConfig: SaveConfig.photo(),
      builder: (CameraState state, Preview preview) => state.when(
        onPhotoMode: (photoCameraState) => SizedBox(key: UniqueKey()),
      ),
    );
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
        children: [
          if (_awesomeBuilder != null) 
            _awesomeBuilder!
          else
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future _processAwesomeImage(AnalysisImage image) async {
    var inputImage = image.toInputImage();
    widget.onImage(inputImage);
  }
}