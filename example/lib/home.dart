import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrz_scanner/mrz_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MRZResult? result;
  _buildRow(icon, text) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('MRZ Scanner'),
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MRZScanner(
                  initialDirection: CameraLensDirection.back,
                  showOverlay: true,
                  onSuccess: (mrzResult) {
                    Navigator.of(context).pop();
                    setState(() {
                      result = mrzResult;
                    });
                  },
                ),
              ),
            );
          },
          child: const Icon(Icons.search),
        );
      }),
      body: result == null
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRow(
                      CupertinoIcons.profile_circled,
                      'Name : ${result!.givenNames}',
                    ),
                    const SizedBox(height: 7),
                    _buildRow(
                      CupertinoIcons.person,
                      'Gender : ${result!.sex.name}',
                    ),
                    const SizedBox(height: 7),
                    _buildRow(
                      Icons.location_on,
                      'CountryCode : ${result!.countryCode}',
                    ),
                    const SizedBox(height: 7),
                    _buildRow(
                      Icons.date_range,
                      'Date of Birth : ${result!.birthDate}',
                    ),
                    const SizedBox(height: 7),
                    _buildRow(
                      Icons.date_range,
                      'Expiry Date : ${result!.expiryDate}',
                    ),
                    const SizedBox(height: 7),
                    _buildRow(
                      CupertinoIcons.number,
                      'DocNum : ${result!.documentNumber}',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
