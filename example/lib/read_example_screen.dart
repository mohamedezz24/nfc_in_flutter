import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class ReadExampleScreen extends StatefulWidget {
  const ReadExampleScreen({super.key});

  @override
  ReadExampleScreenState createState() => ReadExampleScreenState();
}

class ReadExampleScreenState extends State<ReadExampleScreen> {
  StreamSubscription<NDEFMessage>? _stream;

  void _startScanning() {
    setState(() {
      _stream = NFC
          .readNDEF(alertMessage: "Custom message with readNDEF#alertMessage")
          .listen((NDEFMessage message) {
        if (message.isEmpty) {
          debugPrint("Read empty NDEF message");
          return;
        }
        debugPrint("Read NDEF message with ${message.records.length} records");
        for (NDEFRecord record in message.records) {
          debugPrint(
              "Record '${record.id ?? "[NO ID]"}' with TNF '${record.tnf}', type '${record.type}', payload '${record.payload}' and data '${record.data}' and language code '${record.languageCode}'");
        }
      }, onError: (error) {
        setState(() {
          _stream = null;
        });
        if (error is NFCUserCanceledSessionException) {
          debugPrint("user canceled");
        } else if (error is NFCSessionTimeoutException) {
          debugPrint("session timed out");
        } else {
          debugPrint("error: $error");
        }
      }, onDone: () {
        setState(() {
          _stream = null;
        });
      });
    });
  }

  void _stopScanning() {
    _stream?.cancel();
    setState(() {
      _stream = null;
    });
  }

  void _toggleScan() {
    if (_stream == null) {
      _startScanning();
    } else {
      _stopScanning();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stopScanning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Read NFC example"),
      ),
      body: Center(
          child: ElevatedButton(
        onPressed: _toggleScan,
        child: const Text("Toggle scan"),
      )),
    );
  }
}
