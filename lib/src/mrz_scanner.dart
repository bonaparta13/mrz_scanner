import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_scanner/mrz_scanner.dart';
import 'package:mrz_scanner/src/mrz_parser.dart';
import 'package:mrz_scanner/src/mrz_result.dart';
import 'camera_view.dart';
import 'mrz_helper.dart';

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

  @override
  State<MRZScanner> createState() => MRZScannerState();
}

class MRZScannerState extends State<MRZScanner> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;

  /// Resets the scanning state
  void resetScanning() {
    _isBusy = false;
  }

  @override
  void dispose() {
    _canProcess = false;
    _textRecognizer.close();
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

  /// Attempts to parse MRZ data from recognized text lines
  void _parseScannedText(List<String> lines) {
    try {
      final data = MRZParser.parse(lines);
      widget.onSuccess(data, lines);
    } catch (e) {
      debugPrint('MRZ parsing error: $e');
      _isBusy = false;
    }
  }

  /// Processes an image to extract and recognize MRZ text
  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;

    _isBusy = true;

    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final List<String> processedLines = _extractMRZLines(recognizedText.text);
      print(processedLines);
      if (processedLines.length > 2) {
        print('object');
      }
      final List<String>? validMRZLines =
          MRZHelper.getFinalListToParse(processedLines);

      if (validMRZLines != null && validMRZLines.isNotEmpty) {
        _parseScannedText(validMRZLines);
      } else {
        _isBusy = false;
      }
    } catch (e) {
      debugPrint('Text recognition error: $e');
      _isBusy = false;
    }
  }

  /// Extracts potential MRZ lines from recognized text
  List<String> _extractMRZLines(String text) {
    final String trimmedText = text.replaceAll(' ', '');
    final List<String> allLines = trimmedText.split('\n');

    final List<String> mrzLines = [];
    for (final line in allLines) {
      final String processedLine = MRZHelper.testTextLine(line);
      if (processedLine.isNotEmpty) {
        mrzLines.add(processedLine);
      }
    }

    return mrzLines;
  }
}
