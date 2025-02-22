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

  /// Called whenever a barcode/QR code is detected by the `MobileScanner`.
  void onDetect(Barcode barcode, BuildContext context) {
    final String code = barcode.rawValue ?? '';
    if (code.isNotEmpty) {
      // The QR code now returns a URL like:
      // "https://adversarialapps.com/company/<cik>"
      const prefix = "https://adversarialapps.com/company/";
      String cik = code;
      if (code.startsWith(prefix)) {
        cik = code.substring(prefix.length);
      }
      emit(state.copyWith(scannedText: cik));

      // Navigate to the ReportPage using the extracted CIK
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => ReportCubit(CikService())..fetchCompanyDetails(cik),
            child: ReportPage(cik: cik),
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
