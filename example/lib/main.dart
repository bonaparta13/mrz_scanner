import 'package:audioplayers/audioplayers.dart';
import 'package:example/detail.dart';
import 'package:flutter/cupertino.dart';
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
      home: Scaffold(
        body: Builder(builder: (context) {
          return MRZScanner(
            controller: controller,
            steps: [
              StepModel(
                  text: "Kimliğinizin arka yüzünü işaretli alana yerleştirin",
                  function: () => print(
                      "Kimliğinizin arka yüzünü işaretli alana yerleştirin")),
              StepModel(
                  text: "Arka Yüzü Okutun",
                  function: () => print("Arka Yüzü Okutun")),
            ],
            onStart: () {},
            onSuccess: (mrzResult, images, dad, mom) async {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => DetailScreen(
                        mrzResult: mrzResult,
                        imagePath: images,
                        dad: dad,
                        mom: mom),
                  ));
            },
          );
        }),
      ),
    );
  }
}
