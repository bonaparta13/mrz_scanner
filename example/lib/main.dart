import 'package:flutter/material.dart';
import 'package:mrz_scanner/mrz_scanner.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
          onSuccess: (mrzResult, lines) async {
            await showDialog(
              context: context,
              builder: (context) => Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name : ${mrzResult.givenNames}'),
                      Text('Gender : ${mrzResult.sex.name}'),
                      Text('CountryCode : ${mrzResult.countryCode}'),
                      Text('Date of Birth : ${mrzResult.birthDate}'),
                      Text('Expiry Date : ${mrzResult.expiryDate}'),
                      Text('DocNum : ${mrzResult.documentNumber}'),
                      MaterialButton(
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.pop(context);
                          controller.currentState?.resetScanning();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                          child: Text('Reset Scanning'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
