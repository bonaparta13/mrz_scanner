import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';
import 'camera_overlay.dart';

class MRZCameraView extends StatefulWidget {
  const MRZCameraView({
    Key? key,
    required this.onImage,
    this.initialDirection = CameraLensDirection.back,
    required this.showOverlay,
  }) : super(key: key);

  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;
  final bool showOverlay;

  @override
  State<MRZCameraView> createState() => _MRZCameraViewState();
}

class _MRZCameraViewState extends State<MRZCameraView>
    with WidgetsBindingObserver {
  CameraController? _controller;
  int _cameraIndex = 0;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before camera was initialized
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isEmpty) return;

    try {
      _cameraIndex = _findBestCamera(cameras);
      await _startLiveFeed();
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  int _findBestCamera(List<CameraDescription> cameras) {
    // Try to find a camera with the requested direction and 90 degree orientation
    try {
      if (cameras.any((camera) =>
          camera.lensDirection == widget.initialDirection &&
          camera.sensorOrientation == 90)) {
        return cameras.indexWhere((camera) =>
            camera.lensDirection == widget.initialDirection &&
            camera.sensorOrientation == 90);
      }
      // Fall back to any camera with the requested direction
      return cameras.indexWhere(
          (camera) => camera.lensDirection == widget.initialDirection);
    } catch (e) {
      // If no matching camera found, use the first camera
      return 0;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.showOverlay
          ? MRZCameraOverlay(child: _liveFeedBody())
          : _liveFeedBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImageFromGallery,
        tooltip: 'Pick Image',
        child: const Icon(Icons.photo_library),
      ),
    );
  }

  Widget _liveFeedBody() {
    if (_controller == null || !_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final size = MediaQuery.of(context).size;
    // Calculate scale depending on screen and camera ratios
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
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

  Future<void> _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();

      if (!mounted) return;

      await _controller!.startImageStream(_processCameraImage);
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error starting camera feed: $e');
    }
  }

  Future<void> _stopLiveFeed() async {
    if (_controller == null) return;

    try {
      await _controller!.stopImageStream();
      await _controller!.dispose();
      _controller = null;
      _isCameraInitialized = false;
    } catch (e) {
      debugPrint('Error stopping camera feed: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    try {
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage != null) {
        widget.onImage(inputImage);
      }
    } catch (e) {
      debugPrint('Error processing camera image: $e');
    }
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return null;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return null;

    final inputImageMetadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );
    return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
  }

  // New method to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        // User canceled the picker
        return;
      }

      final File imageFile = File(pickedFile.path);
      final inputImage = InputImage.fromFile(imageFile);

      // Temporarily pause the camera stream to process the picked image
      if (_controller != null && _controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      // Process the picked image
      widget.onImage(inputImage);

      // Resume camera stream after a short delay to allow processing
      if (_controller != null && _controller!.value.isInitialized && mounted) {
        await Future.delayed(const Duration(seconds: 2));
        await _controller!.startImageStream(_processCameraImage);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }
}
