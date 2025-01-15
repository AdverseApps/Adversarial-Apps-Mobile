import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'cubit/qr_scan_cubit.dart';
import 'cubit/qr_scan_state.dart';
import 'qr_generate_page.dart';

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
              // --- Top row with two "boxes" ---
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Do nothing or re-navigate to this page
                        // if you want to refresh or something:
                        // Navigator.pushReplacement(...)
                      },
                      child: Container(
                        height: 60,
                        color: Colors.blueAccent,
                        child: const Center(
                          child: Text(
                            'Scan QR Code',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the "Show QR Code" page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QrGeneratePage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 60,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            'Show QR Code',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // --- Camera preview with real-time scanner ---
              Expanded(
                flex: 3,
                child: MobileScanner(
                  onDetect: (barcodeCapture) {
                    final barcodes = barcodeCapture.barcodes;

                    if (barcodes.isNotEmpty) {
                      // Pass the first detected barcode to the cubit
                      cubit.onDetect(barcodes.first);
                    }
                  },
                ),
              ),

              // --- Display the scanned text in a read-only TextField ---
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
                      ),
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
