import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_scan_state.dart';
import 'package:adversarialapps/pages/cubit/report_cubit.dart';
import 'package:adversarialapps/pages/report_page.dart';
import 'package:adversarialapps/services/cik_service.dart';
import 'package:adversarialapps/pages/sam_report_page.dart'; // Import the SAM report page
import 'package:adversarialapps/pages/cubit/sam_report_cubit.dart'; // Import the SAM cubit
import 'package:adversarialapps/services/sam_service.dart'; // Import the SAM service
import 'package:provider/provider.dart';
import 'package:adversarialapps/components/auth_provider.dart';

class QrScanCubit extends Cubit<QrScanState> {
  QrScanCubit() : super(QrScanState.initial());

  /// Called whenever a barcode/QR code is detected by the scanner.
  void onDetect(Barcode barcode, BuildContext context) {
    // Prevent handling if already processed a scan
    if (state.scannedText.isNotEmpty) return;

    final String code = barcode.rawValue ?? '';
    if (code.isNotEmpty) {
      const String secPrefix = "https://adversarialapps.com/company/";
      const String samPrefix = "https://adversarialapps.com/company/sam/";

      // Get the username from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final username = authProvider.username;

      // Check if the QR code is for a SAM company
      if (code.startsWith(samPrefix)) {
        final String uei = code.substring(samPrefix.length);
        emit(state.copyWith(scannedText: uei));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => SamReportCubit(SamService())..fetchCompanyDetails(uei),
              child: SamReportPage(uei: uei, username: username),
            ),
          ),
        ).then((_) {
          // When the report page is popped, clear the scanned text
          clearScannedText();
        });
      } else if (code.startsWith(secPrefix)) {
        // Otherwise, assume it's a SEC company
        final String cik = code.substring(secPrefix.length);
        emit(state.copyWith(scannedText: cik));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => ReportCubit(CikService())..fetchCompanyDetails(cik),
              child: ReportPage(cik: cik, username: username),
            ),
          ),
        ).then((_) {
          // When the report page is popped, clear the scanned text
          clearScannedText();
        });
      } else {
        // Unknown QR code format; you might want to handle this case (e.g., show an error)
        print("Unknown QR code format: $code");
        clearScannedText();
      }
    }
  }

  /// Optional: a helper to clear the scanned text
  void clearScannedText() {
    emit(state.copyWith(scannedText: ''));
  }
}
