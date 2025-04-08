import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// --- Models & State ---

// Update the model to include the source and allow dynamic risk score
class FavoriteCompany {
  final String identifier; // SEC: CIK, SAM: UEI
  final String source; // "SEC" or "SAM"
  final Map<String, dynamic>? companyData;
  final dynamic riskScore; // For SEC: number; for SAM: string ("SAM Compliant", "Expired", "N/A")

  FavoriteCompany({
    required this.identifier,
    required this.source,
    this.companyData,
    required this.riskScore,
  });
}

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState {
  final DashboardStatus status;
  final Map<String, dynamic>? userStatus;
  final List<FavoriteCompany> favorites;
  final String? errorMessage;

  DashboardState({
    this.status = DashboardStatus.initial,
    this.userStatus,
    this.favorites = const [],
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    Map<String, dynamic>? userStatus,
    List<FavoriteCompany>? favorites,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      userStatus: userStatus ?? this.userStatus,
      favorites: favorites ?? this.favorites,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DashboardCubit extends Cubit<DashboardState> {
  final String authToken;
  DashboardCubit({required this.authToken}) : super(DashboardState());

  // Endpoints – adjust these as necessary.
  final String verifyUrl = 'https://adversarialapps.com/api/verify-login';
  final String callPythonUrl = 'https://adversarialapps.com/api/call-python-api';

  /// A helper to parse an 8-character date string (YYYYMMDD) into a DateTime.
  DateTime parseDate(String dateString) {
    if (dateString.length != 8) return DateTime(0);
    final formattedDate =
        '${dateString.substring(0, 4)}-${dateString.substring(4, 6)}-${dateString.substring(6, 8)}';
    return DateTime.tryParse(formattedDate) ?? DateTime(0);
  }

  Future<void> fetchDashboardData() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      // Verify token and get user status.
      final verifyResponse = await http.get(
        Uri.parse(verifyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'auth_token=$authToken',
        },
      );
      if (verifyResponse.statusCode != 200) {
        throw Exception('Token verification failed');
      }
      final verifyData = jsonDecode(verifyResponse.body);
      if (verifyData['success'] != true || verifyData['user'] == null) {
        throw Exception('Invalid token');
      }
      // Build the userStatus map, including role.
      final userStatus = {
        "username": verifyData['user'],
        "role": verifyData['role'] ?? "false"
      };

      // Get favorites by calling the Python API.
      final favoritesResponse = await http.post(
        Uri.parse(callPythonUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"action": "get_favorites", "username": userStatus["username"]}),
      );
      final favoritesJson = jsonDecode(favoritesResponse.body);
      if (favoritesJson['status'] != 'success' ||
          favoritesJson['sec_favorites'] == null ||
          favoritesJson['sam_favorites'] == null) {
        throw Exception('Failed to load favorites');
      }
      final List<dynamic> secFavoritesList = favoritesJson['sec_favorites'];
      final List<dynamic> samFavoritesList = favoritesJson['sam_favorites'];
      List<FavoriteCompany> favorites = [];

      // Process SEC favorites.
      for (var identifier in secFavoritesList) {
        // Fetch SEC data.
        final secResponse = await http.post(
          Uri.parse(callPythonUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"action": "get_sec_data", "search_term": identifier}),
        );
        final secJson = jsonDecode(secResponse.body);
        Map<String, dynamic>? companyData = secJson['company'];

        // Fetch risk score for SEC.
        final riskResponse = await http.post(
          Uri.parse(callPythonUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "action": "get_company_score",
            "identifier": identifier,
            "source": "SEC"
          }),
        );
        final riskJson = jsonDecode(riskResponse.body);
        dynamic riskScore = (riskJson['status'] == 'success' && riskJson['riskScore'] != null)
            ? (riskJson['riskScore'] as num).toDouble()
            : -1.0;

        favorites.add(
          FavoriteCompany(
            identifier: identifier,
            source: "SEC",
            companyData: companyData,
            riskScore: riskScore,
          ),
        );
      }

      // Process SAM favorites.
      for (var identifier in samFavoritesList) {
        // Fetch SAM data (using same API endpoint with action "fetch_sam_data").
        final samResponse = await http.post(
          Uri.parse(callPythonUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"action": "fetch_sam_data", "uei": identifier}),
        );
        final samJson = jsonDecode(samResponse.body);
        Map<String, dynamic>? companyData = samJson['company'];

        // Compute riskScore for SAM companies using expiration_date.
        dynamic riskScore;
        if (companyData != null && companyData['expiration_date'] != null) {
          final expirationDate = parseDate(companyData['expiration_date']);
          final isCompliant = expirationDate.isAfter(DateTime.now());
          riskScore = isCompliant ? "SAM Compliant" : "Expired";
        } else {
          riskScore = "N/A";
        }

        favorites.add(
          FavoriteCompany(
            identifier: identifier,
            source: "SAM",
            companyData: companyData,
            riskScore: riskScore,
          ),
        );
      }

      // Optionally, you could sort favorites (for example, alphabetically by company name or by source).
      emit(state.copyWith(
        status: DashboardStatus.loaded,
        userStatus: userStatus,
        favorites: favorites,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: DashboardStatus.error, errorMessage: e.toString()));
    }
  }
}
