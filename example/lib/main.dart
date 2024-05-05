import 'package:flutter/material.dart';
import 'package:mrz_scanner/mrz_scanner.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MRZController controller = MRZController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return MRZScanner(
          controller: controller,
          showOverlay: true,
          onStart: () {
            print('MRZ Scanner Started');
          },
          onSuccess: (mrzResult, lines) async {
            print('Name : ${mrzResult.givenNames}');
            print('Gender : ${mrzResult.sex.name}');
            print('CountryCode : ${mrzResult.countryCode}');
            print('Date of Birth : ${mrzResult.birthDate}');
            print('Expiry Date : ${mrzResult.expiryDate}');
            print('DocNum : ${mrzResult.documentNumber}');
          },
        );
      }),
    );
  }
}
