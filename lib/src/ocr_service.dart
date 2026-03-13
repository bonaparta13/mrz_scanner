import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class OCRService {
  static const _ocrArgs = {
    'psm': '4',
    'preserve_interword_spaces': '1',
    'tessedit_char_whitelist': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<',
  };

  OCRService._();

  static Future<String> extractText(String imagePath) {
    return FlutterTesseractOcr.extractText(imagePath, args: _ocrArgs);
  }
}
