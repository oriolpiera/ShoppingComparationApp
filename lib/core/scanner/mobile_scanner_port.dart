import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

import 'barcode_scanner_port.dart';

class MobileScannerPort implements BarcodeScannerPort {
  MobileScannerPort(this.context);

  final BuildContext context;

  @override
  Future<String?> scanBarcode() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }

    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _ScannerPage()),
    );
  }
}

class _ScannerPage extends StatefulWidget {
  const _ScannerPage();

  @override
  State<_ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<_ScannerPage> {
  DateTime? _lastScanAt;
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan barcode')),
      body: ReaderWidget(
        onScan: (result) {
          final barcode = result.text?.trim();
          if (barcode == null || barcode.isEmpty) return;

          final now = DateTime.now();
          if (_processing) return;
          if (_lastScanAt != null &&
              now.difference(_lastScanAt!) <
                  const Duration(milliseconds: 1500)) {
            return;
          }

          _processing = true;
          _lastScanAt = now;
          Navigator.of(context).pop(barcode);
        },
        onScanFailure: (result) {
          if (!mounted || _processing || result.error?.isEmpty == true) {
            return;
          }
          _processing = true;
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
