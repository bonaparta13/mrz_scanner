class MRZHelper {
  /// Supported MRZ line lengths
  static const List<int> _supportedLineLengths = [30, 36, 44];
  
  /// Supported document type identifiers
  static const List<String> _supportedDocTypes = ['A', 'C', 'P', 'V', 'I'];
  
  /// Validates and prepares a list of MRZ lines for parsing
  static List<String>? getFinalListToParse(List<String> ableToScanTextList) {
    // Minimum length of any MRZ format is 2 lines
    if (ableToScanTextList.length < 2) {
      return null;
    }
    
    // Check if all lines have the same length
    final int lineLength = ableToScanTextList.first.length;
    if (ableToScanTextList.any((line) => line.length != lineLength)) {
      return null;
    }
    
    // Check if the first character is a supported document type
    final String firstChar = ableToScanTextList.first[0];
    if (_supportedDocTypes.contains(firstChar)) {
      return ableToScanTextList;
    }
    
    return null;
  }

  /// Processes and normalizes a text line for MRZ parsing
  static String testTextLine(String text) {
    // Remove spaces and convert to uppercase
    final String cleanText = text.replaceAll(' ', '');
    
    // Check if the text length matches any supported MRZ format
    if (!_supportedLineLengths.contains(cleanText.length)) {
      return '';
    }

    final List<String> characters = cleanText.split('');
    
    for (int i = 0; i < characters.length; i++) {
      // Convert to uppercase
      characters[i] = characters[i].toUpperCase();
      
      // Replace invalid characters with '<'
      if (!_isValidMRZCharacter(characters[i])) {
        characters[i] = '<';
      }
    }
    
    return characters.join('');
  }
  
  /// Checks if a character is valid for MRZ
  static bool _isValidMRZCharacter(String char) {
    return RegExp(r'^[A-Z0-9_.]+$').hasMatch(char);
  }
}
