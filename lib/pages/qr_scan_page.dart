import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'cubit/qr_scan_cubit.dart';
import 'cubit/qr_scan_state.dart';

class QrScanPage extends StatelessWidget {
  const QrScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QrScanCubit, QrScanState>(
      builder: (context, state) {
        final cubit = context.read<QrScanCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Adversarial Apps QR Scanner'),
          ),
          body: Column(
            children: [
              // Camera preview with a real-time scanner
              Expanded(
                flex: 3,
                child: MobileScanner(
                  onDetect: (barcodeCapture) {
                    final barcodes = barcodeCapture.barcodes;

                    // If you only care about the first barcode scanned:
                    if (barcodes.isNotEmpty) {
                      context.read<QrScanCubit>().onDetect(barcodes.first);
                    }
                  },
                ),
              ),

              // Display the scanned text in a read-only TextField
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        readOnly: true,
                        controller:
                            TextEditingController(text: state.scannedText),
                        decoration: const InputDecoration(
                          labelText: 'Scanned QR Code Text',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          cubit.clearScannedText();
                        },
                        child: const Text('Clear'),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
