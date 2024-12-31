import 'package:mrz_scanner/src/utils/document_type.dart';
import 'package:mrz_scanner/src/utils/mrz_validation.dart';

class MRZHelper {
  static List<String>? getFinalListToParse(List<String> ableToScanTextList) {
    if (ableToScanTextList.length < 2) {
      // minimum length of any MRZ format is 2 lines
      return null;
    }
    int lineLength = ableToScanTextList.first.length;
    for (var e in ableToScanTextList) {
      if (e.length != lineLength) {
        return null;
      }
      // to make sure that all lines are the same in length
    }
    List<String> firstLineChars = ableToScanTextList.first.split('');
    List<String> supportedDocTypes = ['A', 'C', 'P', 'V', 'I'];
    String fChar = firstLineChars[0];
    if (supportedDocTypes.contains(fChar)) {
      return [...ableToScanTextList];
    }
    return null;
  }

  static String testTextLine(String text) {
    text = text.replaceAll('«', '<');
    if (!MrzValidation.validateMrzLine(text)) return '';

    String res = text.replaceAll(' ', '');
    List<String> list = res.split('');

    // to check if the text belongs to any MRZ format or not
    if (list.length != 44 && list.length != 30 && list.length != 36) {
      return '';
    }

    for (int i = 0; i < list.length; i++) {
      if (RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i])) {
        list[i] = list[i].toUpperCase();
      }
      if (double.tryParse(list[i]) == null &&
          !(RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i]))) {
        list[i] = '<';
      }
    }
    String result = list.join('');
    return result;
  }

  static DocumentType? _detectDocumentType(String mrz) {
    switch (mrz.length) {
      case 90:
        return DocumentType.td1;
      case 72:
        return DocumentType.td2; // También puede ser MRV-B
      case 88:
        return DocumentType.td3; // También puede ser MRV-A
      default:
        return null;
    }
  }

  static List<String> parseAndFormatMRZ(String rawMRZ) {
    String formattedMRZ = rawMRZ.replaceAll(';', '<');

    DocumentType? docType = _detectDocumentType(formattedMRZ);

    if (docType == null) {
      throw FormatException('Formato MRZ desconocido: longitud no válida.');
    }

    int lineLength;
    int numLines;

    switch (docType) {
      case DocumentType.td1:
        lineLength = 30;
        numLines = 3;
        break;
      case DocumentType.td2:
        lineLength = 36;
        numLines = 2;
        break;
      case DocumentType.td3:
        lineLength = 44;
        numLines = 2;
        break;
      default:
        throw FormatException('Formato MRZ desconocido: longitud no válida.');
    }

    List<String> lines = [];
    for (int i = 0; i < numLines; i++) {
      int start = i * lineLength;
      int end = start + lineLength;
      lines.add(formattedMRZ.substring(start, end));
    }

    return lines;
  }
}
