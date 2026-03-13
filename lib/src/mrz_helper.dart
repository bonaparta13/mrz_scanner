class MRZHelper {
  static const List<int> _supportedLineLengths = [30, 36, 44];
  static const List<String> _supportedDocTypes = ['A', 'C', 'P', 'V', 'I'];
  static final RegExp _validMRZChar = RegExp(r'^[A-Z0-9<]$');

  MRZHelper._();

  static List<String>? getFinalListToParse(List<String> lines) {
    if (lines.length < 2) return null;

    final int lineLength = lines.first.length;
    if (!_supportedLineLengths.contains(lineLength)) return null;
    if (lines.any((line) => line.length != lineLength)) return null;
    if (!_supportedDocTypes.contains(lines.first[0])) return null;

    return lines;
  }

  static String testTextLine(String text) {
    final String cleaned = text.replaceAll(' ', '').toUpperCase();

    if (!_supportedLineLengths.contains(cleaned.length)) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      final char = cleaned[i];
      buffer.write(_validMRZChar.hasMatch(char) ? char : '<');
    }

    return buffer.toString();
  }
}
