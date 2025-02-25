class QrScanState {
  final String scannedText;

  const QrScanState({required this.scannedText});

  factory QrScanState.initial() {
    return const QrScanState(scannedText: '');
  }

  QrScanState copyWith({String? scannedText}) {
    return QrScanState(
      scannedText: scannedText ?? this.scannedText,
    );
  }
}
