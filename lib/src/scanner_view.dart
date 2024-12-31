import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScannerView extends StatefulWidget {
  final Function(String inputText) onText;

  const ScannerView({super.key, required this.onText});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final _textController = TextEditingController();
  final _textFieldFocusNode = FocusNode();

  Timer? _inputTimer;
  static const int _inputDelay = 1000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_textFieldFocusNode);
    });
    _textController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    _inputTimer?.cancel();
    super.dispose();
  }

  void _onInputChanged() {
    _inputTimer?.cancel();
    _inputTimer = Timer(Duration(milliseconds: _inputDelay), _processInput);
  }

  void _processInput() {
    final inputData = _textController.text.trim();
    if (inputData.isNotEmpty) {
      widget.onText(inputData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(_textFieldFocusNode);
          },
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 5,
                  child: TextField(
                    controller: _textController,
                    focusNode: _textFieldFocusNode,
                    autofocus: true,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    Text(
                      'Escanea el documento',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Lottie.asset(
                      'assets/lottie/document_scan.json', 
                      package: 'mrz_scanner',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}