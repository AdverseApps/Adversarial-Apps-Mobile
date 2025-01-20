import 'package:bloc/bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'qr_scan_state.dart';

class QrScanCubit extends Cubit<QrScanState> {
  QrScanCubit() : super(QrScanState.initial());

  /// Called whenever a barcode/QR code is detected by the `MobileScanner`.
  void onDetect(Barcode barcode) {
    final String code = barcode.rawValue ?? '';
    if (code.isNotEmpty) {
      emit(state.copyWith(scannedText: code));
    }
  }

  /// Optional: a helper to clear the scanned text
  void clearScannedText() {
    emit(state.copyWith(scannedText: ''));
  }
}
