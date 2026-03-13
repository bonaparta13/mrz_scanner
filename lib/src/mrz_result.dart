enum Sex {
  none,
  male,
  female;

  @override
  String toString() {
    switch (this) {
      case Sex.male:
        return 'MALE';
      case Sex.female:
        return 'FEMALE';
      case Sex.none:
        return 'UNSPECIFIED';
    }
  }
}

class MRZResult {
  const MRZResult({
    required this.documentType,
    required this.countryCode,
    required this.surnames,
    required this.givenNames,
    required this.documentNumber,
    required this.nationalityCountryCode,
    required this.birthDate,
    required this.sex,
    required this.expiryDate,
    required this.personalNumber,
    this.personalNumber2,
  });

  final String documentType;
  final String countryCode;
  final String surnames;
  final String givenNames;
  final String documentNumber;
  final String nationalityCountryCode;
  final DateTime birthDate;
  final Sex sex;
  final DateTime expiryDate;
  final String personalNumber;
  final String? personalNumber2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MRZResult &&
          runtimeType == other.runtimeType &&
          documentType == other.documentType &&
          countryCode == other.countryCode &&
          surnames == other.surnames &&
          givenNames == other.givenNames &&
          documentNumber == other.documentNumber &&
          nationalityCountryCode == other.nationalityCountryCode &&
          birthDate == other.birthDate &&
          sex == other.sex &&
          expiryDate == other.expiryDate &&
          personalNumber == other.personalNumber &&
          personalNumber2 == other.personalNumber2;

  @override
  int get hashCode => Object.hash(
        documentType,
        countryCode,
        surnames,
        givenNames,
        documentNumber,
        nationalityCountryCode,
        birthDate,
        sex,
        expiryDate,
        personalNumber,
        personalNumber2,
      );

  @override
  String toString() =>
      'MRZResult(type: $documentType, country: $countryCode, '
      'name: $givenNames $surnames, doc: $documentNumber, '
      'birth: $birthDate, sex: $sex, expiry: $expiryDate)';
}
