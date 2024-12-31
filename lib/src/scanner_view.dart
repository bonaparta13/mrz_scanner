import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScannerView extends StatefulWidget {
  final Function(String inputText) onText;

  const ScannerView({super.key, required this.onText});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final textController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(textFieldFocusNode);
    });
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Scanner View'),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(textFieldFocusNode);
          },
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 5,
                  child: TextField(
                    controller: textController,
                    focusNode: textFieldFocusNode,
                    autofocus: true,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Lottie.asset(
                  'assets/lottie/document_scan.json', 
                  package: 'mrz_scanner',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}