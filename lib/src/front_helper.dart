class FrontHelper {
  static bool testParentsName(List<String> ableToScan) {
    String surname = "";
    String documentNo = "";
    String idNo = "";
    String signature = "";
    for (var e in ableToScan) {
      var _e = e.replaceAll(' ', '').toLowerCase();
      for (var dadName in idNoControl) {
        var _dadName = dadName.replaceAll(" ", "").toLowerCase();
        if (_e.contains(_dadName) &&
            int.tryParse(ableToScan.elementAt(ableToScan.indexOf(e) + 1)) !=
                null) {
          idNo = ableToScan.elementAt(ableToScan.indexOf(e) + 1);
          break;
        }
      }
    }

    for (var e in ableToScan) {
      var _e = e.replaceAll(' ', '').toLowerCase();
      for (var dadName in nationalityControl) {
        var _dadName = dadName.replaceAll(" ", "").toLowerCase();
        if (_e.contains(_dadName)) {
          if (ableToScan.length > ableToScan.indexOf(e) + 1) {
            signature = ableToScan.elementAt(ableToScan.indexOf(e) + 1);
            break;
          }
        }
      }
    }

    for (var e in ableToScan) {
      var _e = e.replaceAll(' ', '').toLowerCase();
      for (var dadName in surnameControl) {
        var _surname = dadName.replaceAll(" ", "").toLowerCase();
        if (_e.contains(_surname)) {
          surname = ableToScan.elementAt(ableToScan.indexOf(e) + 1);
          break;
        }
      }
    }

    for (var e in ableToScan) {
      var _e = e.replaceAll(' ', '').toLowerCase();
      for (var momName in documentNoControl) {
        var _momName = momName.replaceAll(" ", "").toLowerCase();
        if (_e.contains(_momName)) {
          documentNo = ableToScan.elementAt(ableToScan.indexOf(e) + 1);
          break;
        }
      }
    }

    print((surname.isEmpty ? "surname null " : "") +
        " " +
        (documentNo.isEmpty ? "doc no null " : "") +
        " " +
        (idNo.isEmpty ? "id no null " : "") +
        " " +
        (signature.isEmpty ? "imza null " : ""));

    return surname.isNotEmpty && idNo.isNotEmpty && signature.isNotEmpty;
  }

  static final surnameControl = [
    "Soyadı / Surname",
    "Soyadı/Surname",
    "Soyadi/Surname",
    "Soyadi",
    "Surname",
    "Surname",
    "Soyadı",
    "Soyadi",
  ];

  static final documentNoControl = [
    "Seri No / Document No",
    "Seri No/Document",
    "Serı No/Document",
    "Seri No",
    "Serı No",
    "Document No",
    "DocumentNo",
    "SeriNo",
    "SerıNo",
  ];

  static final idNoControl = [
    "Kimlik No / ID No",
    "Kimlik No/ID No",
    "Kimlik No",
    "ID No",
    "IDNo",
    "KimlikNo",
    "T.C. Kimlik No / TR Identity No",
    "T.C. Kimlik No/TR Identity No",
    "T.C. Kimlik No",
    "TR Identity No",
    "TRIdentityNo",
    "TCKimlikNo",
  ];

  static final nationalityControl = [
    "Uyruğu / Nationality",
    "Uyruğu/Nationality",
    "Uyruğu",
    "National",
    "National",
    "Uyruğu",
    "Uyrugu",
  ];
}
