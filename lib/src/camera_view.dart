import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:mrz_scanner/src/camera_format.dart';
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
  CameraController? _controller;
  int _cameraIndex = 0;
  List<CameraDescription> cameras = [];

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  initCamera() async {
    cameras = await availableCameras();

    try {
      if (cameras.any((element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90)) {
        _cameraIndex = cameras.indexOf(
          cameras.firstWhere(
            (element) =>
                element.lensDirection == widget.initialDirection &&
                element.sensorOrientation == 90,
          ),
        );
      } else {
        _cameraIndex = cameras.indexOf(
          cameras.firstWhere(
            (element) => element.lensDirection == widget.initialDirection,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
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
    if (_controller?.value.isInitialized == false ||
        _controller?.value.isInitialized == null) {
      return Container();
    }
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: CameraPreview(_controller!),
          ),
        ],
      ),
    );
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _processCameraImage(CameraImage image) async {
    final camera = cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    // Determine rotation
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // Validate or convert format
    Uint8List? convertedBytes;
    InputImageFormat? format;

    if (Platform.isAndroid) {
      format = InputImageFormat.nv21;
      if (image.format.group == ImageFormatGroup.nv21) {
        convertedBytes = image.planes[0].bytes;
      } else {
        convertedBytes = CameraFormat.convertToNV21(image);
      }
    } else if (Platform.isIOS) {
      format = InputImageFormat.bgra8888;
      convertedBytes = image.planes[0].bytes;
    }
    if (convertedBytes == null || format == null) return null;

    // Create InputImage using the converted bytes
    var inputImage = InputImage.fromBytes(
      bytes: convertedBytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // Used in Android
        format: format, // Used in iOS
        bytesPerRow: image.planes.first.bytesPerRow, // Only needed for BGRA8888
      ),
    );

    widget.onImage(inputImage);
  }
}
