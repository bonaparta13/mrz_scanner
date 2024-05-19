import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrz_scanner/mrz_scanner.dart';

class DetailScreen extends StatefulWidget {
  final MRZResult mrzResult;
  final List<String> imagePath;
  final String dad;
  final String mom;
  const DetailScreen(
      {super.key,
      required this.mrzResult,
      required this.imagePath,
      required this.dad,
      required this.mom});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Screen'),
        ),
        body: ListView(
          children: [
            SizedBox(
                height: 500,
                child: Image.memory(base64Decode(widget.imagePath.first))),
            const SizedBox(height: 10),
            SizedBox(
                height: 500,
                child:
                    Image.memory(base64Decode(widget.imagePath.elementAt(1)))),
            const SizedBox(height: 10),
            SizedBox(
                height: 500,
                child: Image.memory(base64Decode(widget.imagePath.last))),
            SizedBox(height: 10),
            Text("Passport Number : ${widget.mrzResult.documentNumber}"),
            SizedBox(height: 10),
            Text("Baba : ${widget.dad}"),
            SizedBox(height: 10),
            Text("Maa : ${widget.mom}"),
          ],
        ));
  }
}
