import 'package:adversarialapps/pages/cubit/report_cubit.dart';
import 'package:adversarialapps/pages/report_page.dart';
import 'package:adversarialapps/services/cik_service.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'qr_scan_state.dart';

class QrScanCubit extends Cubit<QrScanState> {
  QrScanCubit() : super(QrScanState.initial());

  /// Called whenever a barcode/QR code is detected by the scanner.
  void onDetect(Barcode barcode, BuildContext context) {
    final String code = barcode.rawValue ?? '';
    if (code.isNotEmpty) {
      emit(state.copyWith(scannedText: code));

      // Navigate to the ReportPage with the scanned CIK number
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => ReportCubit(CikService())..fetchCompanyDetails(code),
            child: ReportPage(cik: code),
          ),
        ),
      );
    }
  }

  /// Optional: a helper to clear the scanned text
  void clearScannedText() {
    emit(state.copyWith(scannedText: ''));
  }
}
