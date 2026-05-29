import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
  final MobileScannerController _controller = MobileScannerController();
  DateTime? _lastScanAt;
  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan barcode')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (capture.barcodes.isEmpty) return;
          final barcode = capture.barcodes.first.rawValue?.trim();
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
      ),
    );
  }
}
