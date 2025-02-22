import 'package:adversarialapps/pages/cubit/qr_scan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'cubit/qr_scan_cubit.dart';
import '../components/shared_app_bar.dart';

class QrScanPage extends StatelessWidget {
  const QrScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QrScanCubit, QrScanState>(
      builder: (context, state) {
        final cubit = context.read<QrScanCubit>();

        return Scaffold(
          appBar: const SharedAppBar(title: 'QR Scanner'),
          body: Column(
            children: [
              // Existing row for “Scan QR Code” or “Show QR Code”
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Possibly refresh current page
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
                ],
              ),

              // Camera preview with mobile_scanner
              Expanded(
                flex: 3,
                child: MobileScanner(
                  onDetect: (barcodeCapture) {
                    final barcodes = barcodeCapture.barcodes;

                    if (barcodes.isNotEmpty) {
                      cubit.onDetect(barcodes.first, context);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
