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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(mrzResult: mrzResult),
              ),
            );
          },
        );
      }),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final MRZResult mrzResult;

  const DetailScreen({super.key, required this.mrzResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MRZ Result'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Names : ${mrzResult.givenNames}'),
          Text('Surnames : ${mrzResult.surnames}'),
          Text('Gender : ${mrzResult.sex.name}'),
          Text('CountryCode : ${mrzResult.countryCode}'),
          Text('Date of Birth : ${mrzResult.birthDate}'),
          Text('Expiry Date : ${mrzResult.expiryDate}'),
          Text('DocNum : ${mrzResult.documentNumber}'),

          MaterialButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ),
              );
            },
            child: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }
}
