import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
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
  // Define your API endpoint for calling the Next.js Python API
  final String apiEndpoint = 'https://adversarialapps.com/api/call-python-api';

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

  Future<void> toggleFavorite(String username, String cik) async {
    // Create the POST body for your favorite toggle
    final body = jsonEncode({
      'action': 'add_remove_favorite',
      'username': username,
      "identifier": cik, "source": "SEC",
    });

    try {
      final response = await http.post(
        Uri.parse(apiEndpoint),
        body: body,
        headers: {
          'Content-Type': 'application/json',
          // Include any additional headers if necessary
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Optionally, handle response data (e.g. update state or show a message)
        print('Toggle favorite successful: ${data['message']}');
      } else {
        // Optionally update the state with the error message
        emit(state.copyWith(error: 'Error toggling favorite'));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
