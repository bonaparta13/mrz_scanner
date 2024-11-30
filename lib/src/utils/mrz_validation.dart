class MrzValidation {
  static final RegExp _standarRegex = RegExp(r"([A|C|I][A-Z0-9<]{1})([A-Z]{3})([A-Z0-9<]{9})([0-9]{1})");
  static final RegExp _firstLineregex = RegExp(r"([A|C|I][A-Z0-9<]{1})([A-Z]{3})([A-Z0-9<]{9})([0-9]{1})([A-Z0-9<]{15})");
  static final RegExp _secondLineRegex = RegExp(r"([0-9]{6})([0-9]{1})([M|F|X|<]{1})([0-9]{6})([0-9]{1})([A-Z]{3})([A-Z0-9<]{11})([0-9]{1})");
  static final RegExp _thirdLineRegex = RegExp(r"([A-Z0-9<]{30})");

  static bool validateMrzLine(String mrz) {
    return _standarRegex.hasMatch(mrz) || _firstLineregex.hasMatch(mrz) || _secondLineRegex.hasMatch(mrz) || _thirdLineRegex.hasMatch(mrz);
  }
}