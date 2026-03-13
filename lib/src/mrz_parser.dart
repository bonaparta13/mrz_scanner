import 'mrz_result.dart';

class MRZParser {
  static MRZResult parse(List<String> lines) {
    final format = _detectFormat(lines);

    switch (format) {
      case _MRZFormat.td3:
        return _parseTD3(lines);
      case _MRZFormat.td1:
        return _parseTD1(lines);
      case _MRZFormat.td2:
        return _parseTD2(lines);
      case _MRZFormat.visa:
        return _parseVisa(lines);
    }
  }

  static _MRZFormat _detectFormat(List<String> lines) {
    if (lines.length == 3 && lines[0].length == 30) {
      return _MRZFormat.td1;
    }
    if (lines.length == 2) {
      final len = lines[0].length;
      if (len == 44 && lines[0][0] == 'P') return _MRZFormat.td3;
      if (len == 36 && lines[0][0] != 'V') return _MRZFormat.td2;
      if (lines[0][0] == 'V') return _MRZFormat.visa;
      if (len == 44) return _MRZFormat.td3;
    }
    throw const FormatException('Unknown MRZ format');
  }

  // --- TD3 (passport, 2 lines x 44 chars) ---
  static MRZResult _parseTD3(List<String> lines) {
    final line1 = lines[0];
    final line2 = lines[1];
    final names = _parseNames(line1.substring(5));

    return MRZResult(
      documentType: line1.substring(0, 2).replaceAll('<', '').trim(),
      countryCode: line1.substring(2, 5),
      surnames: names.surnames,
      givenNames: names.givenNames,
      documentNumber: _clean(line2.substring(0, 9)),
      nationalityCountryCode: line2.substring(10, 13),
      birthDate: _parseDate(line2.substring(13, 19)),
      sex: _parseSex(line2.substring(20, 21)),
      expiryDate: _parseDate(line2.substring(21, 27)),
      personalNumber: _clean(line2.substring(28, 42)),
    );
  }

  // --- TD1 (ID card, 3 lines x 30 chars) ---
  static MRZResult _parseTD1(List<String> lines) {
    final line1 = lines[0];
    final line2 = lines[1];
    final line3 = lines[2];
    final names = _parseNames(line3);

    return MRZResult(
      documentType: line1.substring(0, 2).replaceAll('<', '').trim(),
      countryCode: line1.substring(2, 5),
      surnames: names.surnames,
      givenNames: names.givenNames,
      documentNumber: _clean(line1.substring(5, 14)),
      nationalityCountryCode: line2.substring(15, 18),
      birthDate: _parseDate(line2.substring(0, 6)),
      sex: _parseSex(line2.substring(7, 8)),
      expiryDate: _parseDate(line2.substring(8, 14)),
      personalNumber: _clean(line1.substring(15)),
    );
  }

  // --- TD2 (ID card, 2 lines x 36 chars) ---
  static MRZResult _parseTD2(List<String> lines) {
    final line1 = lines[0];
    final line2 = lines[1];
    final names = _parseNames(line1.substring(5));

    return MRZResult(
      documentType: line1.substring(0, 2).replaceAll('<', '').trim(),
      countryCode: line1.substring(2, 5),
      surnames: names.surnames,
      givenNames: names.givenNames,
      documentNumber: _clean(line2.substring(0, 9)),
      nationalityCountryCode: line2.substring(10, 13),
      birthDate: _parseDate(line2.substring(13, 19)),
      sex: _parseSex(line2.substring(20, 21)),
      expiryDate: _parseDate(line2.substring(21, 27)),
      personalNumber: _clean(line2.substring(28)),
    );
  }

  // --- Visa (MRVA 44 chars / MRVB 36 chars) ---
  static MRZResult _parseVisa(List<String> lines) {
    final line1 = lines[0];
    final line2 = lines[1];
    final names = _parseNames(line1.substring(5));

    return MRZResult(
      documentType: line1.substring(0, 2).replaceAll('<', '').trim(),
      countryCode: line1.substring(2, 5),
      surnames: names.surnames,
      givenNames: names.givenNames,
      documentNumber: _clean(line2.substring(0, 9)),
      nationalityCountryCode: line2.substring(10, 13),
      birthDate: _parseDate(line2.substring(13, 19)),
      sex: _parseSex(line2.substring(20, 21)),
      expiryDate: _parseDate(line2.substring(21, 27)),
      personalNumber: _clean(line2.substring(28)),
    );
  }

  // --- Shared helpers ---

  static _Names _parseNames(String raw) {
    final parts = raw.split('<<');
    final surnames =
        parts.isNotEmpty ? parts.first.replaceAll('<', ' ').trim() : '';
    final givenNames =
        parts.length > 1 ? parts.sublist(1).join(' ').replaceAll('<', ' ').trim() : '';
    return _Names(surnames: surnames, givenNames: givenNames);
  }

  static String _clean(String raw) => raw.replaceAll('<', '').trim();

  static DateTime _parseDate(String raw) {
    final year = int.parse(raw.substring(0, 2));
    final month = int.parse(raw.substring(2, 4));
    final day = int.parse(raw.substring(4, 6));
    final century = (year <= DateTime.now().year % 100) ? 2000 : 1900;
    return DateTime(century + year, month, day);
  }

  static Sex _parseSex(String value) {
    switch (value) {
      case 'M':
        return Sex.male;
      case 'F':
        return Sex.female;
      default:
        return Sex.none;
    }
  }
}

enum _MRZFormat { td3, td1, td2, visa }

class _Names {
  const _Names({required this.surnames, required this.givenNames});
  final String surnames;
  final String givenNames;
}
