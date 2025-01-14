import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/qr_scan_cubit.dart';
import 'cubit/qr_scan_state.dart';

class QrScanPage extends StatelessWidget {
  const QrScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We will listen to the QrScanCubit
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adversarial Apps QR Scanner'),
      ),
      body: BlocBuilder<QrScanCubit, QrScanState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display scanned text
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(text: state.scannedText),
                    decoration: const InputDecoration(
                      labelText: 'Scanned QR Code Text',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error message if any
                  if (state.errorMessage != null)
                    Text(
                      'Error: ${state.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 20),

                  // Button to scan
                  ElevatedButton(
                    onPressed: state.isScanning
                        ? null
                        : () {
                            // Trigger the Cubit scan
                            context.read<QrScanCubit>().scanQrCode();
                          },
                    child: state.isScanning
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Scan QR Code'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
