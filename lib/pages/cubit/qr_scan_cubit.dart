import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_scan_state.dart';
import 'package:adversarialapps/pages/cubit/report_cubit.dart';
import 'package:adversarialapps/pages/report_page.dart';
import 'package:adversarialapps/services/cik_service.dart';
import 'package:provider/provider.dart';
import 'package:adversarialapps/components/auth_provider.dart';

class QrScanCubit extends Cubit<QrScanState> {
  QrScanCubit() : super(QrScanState.initial());

  /// Called whenever a barcode/QR code is detected by the scanner.
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

      // Get the username from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final username = authProvider.username;

      // Navigate to the ReportPage using the extracted CIK and username
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => ReportCubit(CikService())..fetchCompanyDetails(cik),
            child: ReportPage(cik: cik, username: username),
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
