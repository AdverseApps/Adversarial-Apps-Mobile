class QrScanState {
  final String scannedText;
  final bool isScanning;
  final String? errorMessage;

  const QrScanState({
    required this.scannedText,
    required this.isScanning,
    this.errorMessage,
  });

  /// Initial/default state
  factory QrScanState.initial() {
    return const QrScanState(
      scannedText: '',
      isScanning: false,
      errorMessage: null,
    );
  }

  QrScanState copyWith({
    String? scannedText,
    bool? isScanning,
    String? errorMessage,
  }) {
    return QrScanState(
      scannedText: scannedText ?? this.scannedText,
      isScanning: isScanning ?? this.isScanning,
      errorMessage: errorMessage,
    );
  }
}
