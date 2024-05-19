import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

class CropImageHelper {
  static Future<String?> takePicture(
      XFile image, GlobalKey containerKey, BuildContext context) async {
    try {
      // Resmi çek

      // Resmin dosya yolunu alys
      final imagePath = image.path;

      // Container'ın konumunu ve boyutunu al
      RenderBox? renderBox =
          containerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        log("Container not found");
        return null;
      }

      // Container'ın konumunu ve boyutunu hesapla
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      // Resmi oku
      final img.Image capturedImage =
          img.decodeImage(File(imagePath).readAsBytesSync())!;

      // Ekran boyutlarını al
      final ui.Size screenSize = MediaQuery.of(context).size;

      // Container'ın kameradaki pozisyonunu hesapla
      final double scaleX = capturedImage.width / screenSize.width;
      final double scaleY = capturedImage.height / screenSize.height;

      final int cropX = (position.dx * scaleX).toInt();
      final int cropY = (position.dy * scaleY).toInt();
      final int cropWidth = (size.width * scaleX).toInt();
      final int cropHeight = (size.height * scaleY).toInt();

      // Resmi kırp
      final img.Image croppedImage = img.copyCrop(capturedImage,
          x: cropX, y: cropY, width: cropWidth, height: cropHeight);

      // base64'e çevir
      var base64Image = base64Encode(img.encodeJpg(croppedImage));

      return base64Image;
    } catch (e) {
      log("Error in crop_image_helper.dart: $e");
      return null;
    }
  }

  static Future<InputImage?> cropProcessImage(
      BuildContext context,
      XFile cameraImage,
      GlobalKey _containerKey,
      CameraDescription camera) async {
    var base64 = await takePicture(cameraImage, _containerKey, context);
    final imageRotation = InputImageRotationValue.fromRawValue(90);

    final inputImageFormat = InputImageFormatValue.fromRawValue(1111970369);

    final inputImage = InputImage.fromBytes(
      bytes: base64Decode(base64!),
      metadata: InputImageMetadata(
          size: Size(1920, 1080),
          rotation: imageRotation!,
          format: inputImageFormat!,
          bytesPerRow: 8),
    );

    return inputImage;
  }

  static Future<String?> cropPersonPhotoFromFront(
      String frontImage, Face face) async {
    try {
      // Resmi oku
      final img.Image capturedImage =
          img.decodeImage(base64Decode(frontImage))!;

      // Yüzün konumunu ve boyutunu al
      final int x = face.headEulerAngleX!.toInt();
      final int y = face.headEulerAngleY!.toInt();
      final int width = 200;
      final int height = 320;

      // Yüzü kırp
      final img.Image croppedImage =
          img.copyCrop(capturedImage, x: x, y: y, width: width, height: height);

      // base64'e çevir
      var base64Image = base64Encode(img.encodeJpg(croppedImage));

      return base64Image;
    } catch (e) {
      log("Error in crop_image_helper.dart: $e");
      return null;
    }
  }
}
