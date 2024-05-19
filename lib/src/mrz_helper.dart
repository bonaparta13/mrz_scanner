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
    String res = text.replaceAll(' ', '');
    List<String> list = res.split('');

    // to check if the text belongs to any MRZ format or not
    if (list.length != 44 && list.length != 30 && list.length != 36) {
      return '';
    }

    for (int i = 0; i < list.length; i++) {
      if (RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i])) {
        list[i] = list[i].toUpperCase();
        // to ensure that every letter is uppercase
      }
      if (double.tryParse(list[i]) == null &&
          !(RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i]))) {
        list[i] = '<';
        // sometimes < sign not recognized well
      }
    }
    String result = list.join('');
    return result;
  }

  static (String, String) testParentsName(List<String> ableToScan) {
    String dadNameIndex = "";
    String momNameIndex = "";
    for (var e in ableToScan) {
      var _e = e.replaceAll(' ', '').toLowerCase();
      for (var dadName in dadNameControl) {
        var _dadName = dadName.replaceAll(" ", "").toLowerCase();
        if (_e.contains(_dadName)) {
          dadNameIndex = ableToScan.elementAt(ableToScan.indexOf(e) + 1);
          break;
        }
      }
    }

    for (var e in ableToScan) {
      var _e = e.replaceAll(' ', '').toLowerCase();
      for (var momName in momNameControl) {
        var _momName = momName.replaceAll(" ", "").toLowerCase();
        if (_e.contains(_momName)) {
          momNameIndex = ableToScan.elementAt(ableToScan.indexOf(e) + 1);
          break;
        }
      }
    }

    return (dadNameIndex, momNameIndex);
  }

  static final dadNameControl = [
    "Baba Adı / Father's Name",
    "Baba Adı/Father's Name",
    "Baba Adi/Father's Name",
    "Baba Adi",
    "Father's Name",
    "Father'sName",
    "BabaAdı",
    "BabaAdi",
  ];

  static final momNameControl = [
    "Anne Adı / Mother's Name",
    "Anne Adı/Mother's Name",
    "Anne Adi/Mother's Name",
    "Anne Adi",
    "Mother's Name",
    "Mother'sName",
    "AnneAdı",
    "AnneAdi",
  ];
}
