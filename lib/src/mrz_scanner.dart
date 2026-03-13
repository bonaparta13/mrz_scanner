import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'mrz_controller.dart';
import 'mrz_helper.dart';
import 'mrz_parser.dart';
import 'mrz_result.dart';
import 'camera_view.dart';
import 'ocr_service.dart';

class MRZScanner extends StatefulWidget {
  const MRZScanner({
    Key? key,
    required this.onSuccess,
    this.initialDirection = CameraLensDirection.back,
    this.showOverlay = true,
    this.controller,
  }) : super(key: key);

  final Function(MRZResult mrzResult, List<String> lines) onSuccess;
  final CameraLensDirection initialDirection;
  final bool showOverlay;
  final MRZController? controller;

  /// Scans an image file at [imagePath] and returns the parsed MRZ result.
  ///
  /// Throws [FormatException] if no valid MRZ is found in the image.
  static Future<MRZResult> scanImage(String imagePath) async {
    final text = await OCRService.extractText(imagePath);
    final lines = _extractMRZLines(text);
    final validLines = MRZHelper.getFinalListToParse(lines);

    if (validLines == null || validLines.isEmpty) {
      throw const FormatException('No valid MRZ found in image');
    }

    return MRZParser.parse(validLines);
  }

  static List<String> _extractMRZLines(String text) {
    return text
        .replaceAll(' ', '')
        .split('\n')
        .map(MRZHelper.testTextLine)
        .where((line) => line.isNotEmpty)
        .toList();
  }

  @override
  State<MRZScanner> createState() => MRZScannerState();
}

class MRZScannerState extends State<MRZScanner> {
  bool _canProcess = true;
  bool _isBusy = false;

  void resetScanning() {
    _isBusy = false;
  }

  @override
  void dispose() {
    _canProcess = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MRZCameraView(
      showOverlay: widget.showOverlay,
      initialDirection: widget.initialDirection,
      onImage: _processImage,
    );
  }

  Future<void> _processImage(String recognizedText) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    try {
      final lines = MRZScanner._extractMRZLines(recognizedText);
      final validLines = MRZHelper.getFinalListToParse(lines);

      if (validLines != null && validLines.isNotEmpty) {
        final result = MRZParser.parse(validLines);
        widget.onSuccess(result, validLines);
      } else {
        _isBusy = false;
      }
    } catch (e) {
      debugPrint('MRZ processing error: $e');
      _isBusy = false;
    }
  }
}
