import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:adversarialapps/services/sam_service.dart'; // adjust the import path accordingly

// Define the state
class SamReportState extends Equatable {
  final bool isLoading;
  final Map<String, dynamic>? companyDetails;
  final String? error;

  const SamReportState({
    this.isLoading = false,
    this.companyDetails,
    this.error,
  });

  SamReportState copyWith({
    bool? isLoading,
    Map<String, dynamic>? companyDetails,
    String? error,
  }) {
    return SamReportState(
      isLoading: isLoading ?? this.isLoading,
      companyDetails: companyDetails ?? this.companyDetails,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, companyDetails, error];
}

class SamReportCubit extends Cubit<SamReportState> {
  final SamService _samService;
  // Same API endpoint for toggling favorites
  final String apiEndpoint = 'https://adversarialapps.com/api/call-python-api';

  SamReportCubit(this._samService) : super(const SamReportState());

  Future<void> fetchCompanyDetails(String uei) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final data = await _samService.getCompanyDetails(uei);
      emit(state.copyWith(isLoading: false, companyDetails: data));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> toggleFavorite(String username, String uei) async {
    // For SAM companies, set the source as "SAM"
    final body = jsonEncode({
      'action': 'add_remove_favorite',
      'username': username,
      "identifier": uei,
      "source": "SAM",
    });

    try {
      final response = await http.post(
        Uri.parse(apiEndpoint),
        body: body,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Optionally, handle response data (e.g. update state or show a message)
        print('Toggle favorite successful: ${data['message']}');
      } else {
        emit(state.copyWith(error: 'Error toggling favorite'));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
