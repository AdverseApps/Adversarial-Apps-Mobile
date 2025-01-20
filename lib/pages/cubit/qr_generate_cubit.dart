import 'package:bloc/bloc.dart';
import 'qr_generate_state.dart';

class QrGenerateCubit extends Cubit<QrGenerateState> {
  QrGenerateCubit() : super(QrGenerateState.initial());

  void updateText(String newText) {
    emit(state.copyWith(inputText: newText));
  }
}
