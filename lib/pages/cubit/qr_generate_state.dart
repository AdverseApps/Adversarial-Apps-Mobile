class QrGenerateState {
  final String inputText;

  const QrGenerateState({required this.inputText});

  /// Initial/default state
  factory QrGenerateState.initial() => const QrGenerateState(inputText: '');

  QrGenerateState copyWith({String? inputText}) {
    return QrGenerateState(
      inputText: inputText ?? this.inputText,
    );
  }
}
