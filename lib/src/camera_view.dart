import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'camera_overlay.dart';
import 'ocr_service.dart';

class MRZCameraView extends StatefulWidget {
  const MRZCameraView({
    Key? key,
    required this.onImage,
    this.initialDirection = CameraLensDirection.back,
    required this.showOverlay,
  }) : super(key: key);

  final Function(String recognizedText) onImage;
  final CameraLensDirection initialDirection;
  final bool showOverlay;

  @override
  State<MRZCameraView> createState() => _MRZCameraViewState();
}

class _MRZCameraViewState extends State<MRZCameraView>
    with WidgetsBindingObserver {
  Timer? _captureTimer;
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _captureTimer?.cancel();
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.showOverlay
          ? MRZCameraOverlay(child: _buildCameraPreview())
          : _buildCameraPreview(),
    );
  }

  Widget _buildCameraPreview() {
    if (_controller == null || !_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: scale,
            child: CameraPreview(_controller!),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final cameraIndex = _findBestCamera(cameras);
    _controller = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;

      setState(() => _isCameraInitialized = true);
      _startPeriodicCapture();
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  int _findBestCamera(List<CameraDescription> cameras) {
    final preferred = cameras.indexWhere((c) =>
        c.lensDirection == widget.initialDirection &&
        c.sensorOrientation == 90);
    if (preferred != -1) return preferred;

    final fallback = cameras.indexWhere(
        (c) => c.lensDirection == widget.initialDirection);
    return fallback != -1 ? fallback : 0;
  }

  void _startPeriodicCapture() {
    _captureTimer?.cancel();
    _captureTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _captureAndRecognize(),
    );
  }

  Future<void> _captureAndRecognize() async {
    if (!_isCameraInitialized || _controller == null || _isProcessing) return;
    _isProcessing = true;

    try {
      final picture = await _controller!.takePicture();
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(picture.path).copy(filePath);

      try {
        final text = await OCRService.extractText(filePath);
        widget.onImage(text);
      } finally {
        await savedImage.delete().catchError((_) => savedImage);
      }
    } catch (e) {
      debugPrint('OCR capture error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _disposeCamera() async {
    _captureTimer?.cancel();
    final controller = _controller;
    _controller = null;
    _isCameraInitialized = false;

    try {
      await controller?.dispose();
    } catch (e) {
      debugPrint('Camera dispose error: $e');
    }
  }
}
