import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:adversarialapps/services/cik_service.dart';

class ReportState extends Equatable {
  final bool isLoading;
  final Map<String, dynamic>? companyDetails;
  final String? error;

  const ReportState({
    this.isLoading = false,
    this.companyDetails,
    this.error,
  });

  ReportState copyWith({
    bool? isLoading,
    Map<String, dynamic>? companyDetails,
    String? error,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      companyDetails: companyDetails ?? this.companyDetails,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, companyDetails, error];
}

class ReportCubit extends Cubit<ReportState> {
  final CikService _cikService;

  ReportCubit(this._cikService) : super(const ReportState());

  Future<void> fetchCompanyDetails(String cik) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final data = await _cikService.getCompanyDetails(cik);
      emit(state.copyWith(isLoading: false, companyDetails: data));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
