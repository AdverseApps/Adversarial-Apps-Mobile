class QrGenerateState {
  final String inputText;

  const QrGenerateState({required this.inputText});

  factory QrGenerateState.initial() => const QrGenerateState(inputText: '');

  QrGenerateState copyWith({String? inputText}) {
    return QrGenerateState(
      inputText: inputText ?? this.inputText,
    );
  }
}
