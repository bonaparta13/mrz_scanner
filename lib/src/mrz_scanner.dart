import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_scanner/mrz_scanner.dart';
import 'package:mrz_scanner/src/crop_image_helper.dart';
import 'package:mrz_scanner/src/front_helper.dart';
import 'package:mrz_scanner/src/step_model.dart';
import 'camera_view.dart';
import 'mrz_helper.dart';

class MRZScanner extends StatefulWidget {
  const MRZScanner({
    Key? controller,
    required this.onSuccess,
    this.initialDirection = CameraLensDirection.back,
    this.onStart,
    required this.steps,
  }) : super(key: controller);
  final Function(
          MRZResult mrzResult, List<String> images, String dad, String mom)
      onSuccess;
  final CameraLensDirection initialDirection;
  final Function? onStart;
  final List<StepModel> steps;
  @override
  // ignore: library_private_types_in_public_api
  MRZScannerState createState() => MRZScannerState();
}

class MRZScannerState extends State<MRZScanner> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final FaceDetector _faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate));
  bool _canProcess = true;
  bool _isBusy = false;
  List result = [];
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  int _cameraIndex = 0;

  /// 1. Front
  /// 2. Front Profile Photo
  /// 3. Back

  List<String> _images = [];

  final GlobalKey _containerKey = GlobalKey();

  int _pageIndex = 0;
  void resetScanning() => _isBusy = false;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initCamera();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        MRZCameraView(
          controller: _controller!,
          initialDirection: widget.initialDirection,
          onImage: _processImage,
          onStart: widget.steps.first.function,
          containerKey: _containerKey,
        ),
        Positioned(bottom: 50, left: 20, right: 20, child: _buildLoading()),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
        child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width - 70,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(width: 2, color: Color(0xff4a3aff)),
                color: Color.fromRGBO(38, 38, 38, .9)),
            child: Center(
              child: Text(
                widget.steps[_pageIndex].text ?? "Scanning...",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            )));
  }

  Future initCamera() async {
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
      print(e);
    }

    _controller = CameraController(
      cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    setState(() {});
  }

  void _parseScannedText(
      List<String> lines, (String, String) parentsNames) async {
    try {
      final data = MRZParser.parse(lines);

      _isBusy = true;

      var backImage = await _controller!.takePicture();

      String? imageBase64 =
          await CropImageHelper.takePicture(backImage, _containerKey, context);
      if (imageBase64 == null) {
        _isBusy = false;
        return;
      }

      _images.add(imageBase64);
      widget.onSuccess(data, _images, parentsNames.$1, parentsNames.$2);
    } catch (e) {
      _isBusy = false;
    }
  }

  Future<bool> _processImage(InputImage inputImage) async {
    if (!_canProcess) return false;
    if (_isBusy) return false;
    _isBusy = true;

    final recognizedText = await _textRecognizer.processImage(inputImage);
    String fullText = recognizedText.text;

    String trimmedText = fullText.replaceAll(' ', '');
    List allText = trimmedText.split('\n');
    List<String> ableToScanText = [];
    for (var e in allText) {
      if (MRZHelper.testTextLine(e).isNotEmpty) {
        ableToScanText.add(MRZHelper.testTextLine(e));
      }
    }

    if (_pageIndex == 0) {
      _images.clear();
      var res = FrontHelper.testParentsName(allText as List<String>);
      if (res) {
        print("res: $res");
        List<Face> face = await _faceDetector.processImage(inputImage);
        if (face.isEmpty) {
          _isBusy = false;
          return false;
        }

        var frontImage = await _controller!.takePicture();

        String? imageBase64 = await CropImageHelper.takePicture(
            frontImage, _containerKey, context);

        if (imageBase64 == null) {
          _isBusy = false;
          return false;
        }

        var profilePhoto = await CropImageHelper.cropPersonPhotoFromFront(
            imageBase64, face.first);
        if (profilePhoto == null) {
          _isBusy = false;
          return false;
        }
        _images.add(imageBase64);
        _images.add(profilePhoto);

        _pageIndex = 1;
        _isBusy = false;
        widget.steps[_pageIndex].function!();
        setState(() {});
        return false;
      }
      _isBusy = false;
      setState(() {});
      return false;
    }

    var _parentsName = MRZHelper.testParentsName(allText as List<String>);

    List<String>? result = MRZHelper.getFinalListToParse([...ableToScanText]);

    if (result != null &&
        _parentsName.$1.isNotEmpty &&
        _parentsName.$2.isNotEmpty) {
      _parseScannedText([...result], _parentsName);
      return true;
    } else {
      _isBusy = false;
      await Future.delayed(Duration(seconds: 1));
      return false;
    }
  }
}
