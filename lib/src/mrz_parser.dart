import 'package:mrz_scanner/src/mrz_result.dart';

class MRZParser {
  static MRZResult parse(List<String> lines) {
    if (lines.length == 2 && lines[0].length == 44 && lines[1].length == 44) {
      return _parseTD3(lines);
    } else if (lines.length == 3 && lines[0].length == 30) {
      return _parseTD1(lines);
    } else if (lines.length == 2 &&
        lines[0].length == 36 &&
        lines[1].length == 36) {
      return _parseTD2(lines);
    } else if (lines.length == 2 &&
        (lines[0].length == 44 || lines[0].length == 36)) {
      return _parseVisa(lines);
    } else {
      throw Exception("Unknown MRZ format");
    }
  }

  // --- TD3 (passport) ---
  static MRZResult _parseTD3(List<String> lines) {
    final line1 = lines[0];
    final line2 = lines[1];

    final documentType = line1.substring(0, 1);
    final countryCode = line1.substring(2, 5);

    final namesPart = line1.substring(5).replaceAll('<', ' ').trim();
    final parts = namesPart.split(RegExp(r'\s{2,}'));
    final surnames = parts.isNotEmpty ? parts.first.trim() : '';
    final givenNames =
        parts.length > 1 ? parts.sublist(1).join(' ').trim() : '';

    final documentNumber = line2.substring(0, 9).replaceAll('<', '');
    final nationalityCountryCode = line2.substring(10, 13);
    final birthDate = _parseDate(line2.substring(13, 19));
    final sex = _mapSex(line2.substring(20, 21));
    final expiryDate = _parseDate(line2.substring(21, 27));
    final personalNumber = line2.substring(28, 42).replaceAll('<', '').trim();

    return MRZResult(
      documentType: documentType,
      countryCode: countryCode,
      surnames: surnames,
      givenNames: givenNames,
      documentNumber: documentNumber,
      nationalityCountryCode: nationalityCountryCode,
      birthDate: birthDate,
      sex: sex,
      expiryDate: expiryDate,
      personalNumber: personalNumber,
    );
  }

  // --- TD1 (ID, 3 lines × 30 chars) ---
  static MRZResult _parseTD1(List<String> lines) {
    final line1 = lines[0];
    final line2 = lines[1];
    final line3 = lines[2];

    final documentType = line1.substring(0, 1);
    final countryCode = line1.substring(2, 5);
    final documentNumber = line1.substring(5, 14).replaceAll('<', '');
    final personalNumber = line1.substring(15).replaceAll('<', '');

    final birthDate = _parseDate(line2.substring(0, 6));
    final sex = _mapSex(line2.substring(7, 8));
    final expiryDate = _parseDate(line2.substring(8, 14));
    final nationalityCountryCode = line2.substring(15, 18);

    final namesPart = line3.replaceAll('<', ' ').trim();
    final parts = namesPart.split(RegExp(r'\s{2,}'));
    final surnames = parts.isNotEmpty ? parts.first.trim() : '';
    final givenNames =
        parts.length > 1 ? parts.sublist(1).join(' ').trim() : '';

    return MRZResult(
      documentType: documentType,
      countryCode: countryCode,
      surnames: surnames,
      givenNames: givenNames,
      documentNumber: documentNumber,
      nationalityCountryCode: nationalityCountryCode,
      birthDate: birthDate,
      sex: sex,
      expiryDate: expiryDate,
      personalNumber: personalNumber,
    );
  }

  // --- TD2 (ID, 2 lines × 36 chars) ---
  static MRZResult _parseTD2(List<String> lines) {
    final line1 = lines[0];
    final line2 = lines[1];

    final documentType = line1.substring(0, 1);
    final countryCode = line1.substring(2, 5);

    final namesPart = line1.substring(5).replaceAll('<', ' ').trim();
    final parts = namesPart.split(RegExp(r'\s{2,}'));
    final surnames = parts.isNotEmpty ? parts.first.trim() : '';
    final givenNames =
        parts.length > 1 ? parts.sublist(1).join(' ').trim() : '';

    final documentNumber = line2.substring(0, 9).replaceAll('<', '');
    final nationalityCountryCode = line2.substring(10, 13);
    final birthDate = _parseDate(line2.substring(13, 19));
    final sex = _mapSex(line2.substring(20, 21));
    final expiryDate = _parseDate(line2.substring(21, 27));
    final personalNumber = line2.substring(28).replaceAll('<', '');

    return MRZResult(
      documentType: documentType,
      countryCode: countryCode,
      surnames: surnames,
      givenNames: givenNames,
      documentNumber: documentNumber,
      nationalityCountryCode: nationalityCountryCode,
      birthDate: birthDate,
      sex: sex,
      expiryDate: expiryDate,
      personalNumber: personalNumber,
    );
  }

  // --- Visa (MRVA / MRVB) ---
  static MRZResult _parseVisa(List<String> lines) {
    final line1 = lines[0];
    final line2 = lines[1];

    final documentType = line1.substring(0, 1);
    final countryCode = line1.substring(2, 5);

    final namesPart = line1.substring(5).replaceAll('<', ' ').trim();
    final parts = namesPart.split(RegExp(r'\s{2,}'));
    final surnames = parts.isNotEmpty ? parts.first.trim() : '';
    final givenNames =
        parts.length > 1 ? parts.sublist(1).join(' ').trim() : '';

    final documentNumber = line2.substring(0, 9).replaceAll('<', '');
    final nationalityCountryCode = line2.substring(10, 13);
    final birthDate = _parseDate(line2.substring(13, 19));
    final sex = _mapSex(line2.substring(20, 21));
    final expiryDate = _parseDate(line2.substring(21, 27));
    final personalNumber = line2.substring(28).replaceAll('<', '');

    return MRZResult(
      documentType: documentType,
      countryCode: countryCode,
      surnames: surnames,
      givenNames: givenNames,
      documentNumber: documentNumber,
      nationalityCountryCode: nationalityCountryCode,
      birthDate: birthDate,
      sex: sex,
      expiryDate: expiryDate,
      personalNumber: personalNumber,
    );
  }

  // --- helpers ---
  static DateTime _parseDate(String raw) {
    final year = int.parse(raw.substring(0, 2));
    final month = int.parse(raw.substring(2, 4));
    final day = int.parse(raw.substring(4, 6));

    final currentYear = DateTime.now().year % 100;
    final century = (year <= currentYear ? 2000 : 1900);

    return DateTime(century + year, month, day);
  }

  static Sex _mapSex(String sex) {
    if (sex == 'M') return Sex.male;
    if (sex == 'F') return Sex.female;
    return Sex.none;
  }
}
