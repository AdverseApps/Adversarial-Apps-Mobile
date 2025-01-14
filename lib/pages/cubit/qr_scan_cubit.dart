import 'package:bloc/bloc.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

import 'qr_scan_state.dart';

class QrScanCubit extends Cubit<QrScanState> {
  QrScanCubit() : super(QrScanState.initial());

  /// Initiates QR Code scan using barcode_scan2.
  Future<void> scanQrCode() async {
    try {
      emit(state.copyWith(isScanning: true, errorMessage: null));

      final scanResult = await BarcodeScanner.scan();

      if (scanResult.type == ResultType.Barcode) {
        // Successfully scanned a QR/Barcode
        emit(state.copyWith(
          scannedText: scanResult.rawContent,
          isScanning: false,
        ));
      } else {
        // User canceled or some other event
        emit(state.copyWith(isScanning: false));
      }
    } catch (e) {
      emit(state.copyWith(isScanning: false, errorMessage: e.toString()));
    }
  }
}
