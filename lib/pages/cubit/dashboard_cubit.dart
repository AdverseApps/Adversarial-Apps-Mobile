import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// --- Models & State ---

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

class FavoriteCompany {
  final String cik;
  final Map<String, dynamic>? companyData;
  final int riskScore;

  FavoriteCompany({
    required this.cik,
    this.companyData,
    required this.riskScore,
  });
}

// --- Cubit Implementation ---

class DashboardCubit extends Cubit<DashboardState> {
  final String authToken;
  DashboardCubit({required this.authToken}) : super(DashboardState());

  // Endpoints – adjust these as necessary
  final String verifyUrl = 'https://adversarialapps.com/api/verify-login';
  final String callPythonUrl =
      'https://adversarialapps.com/api/call-python-api';

  Future<void> fetchDashboardData() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      // Verify token and get user status
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
      // Build userStatus map – including role
      final userStatus = {
        "username": verifyData['user'],
        "role": verifyData['role'] ?? "false"
      };

      // Get favorites by calling the Python API
      final favoritesResponse = await http.post(
        Uri.parse(callPythonUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {"action": "get_favorites", "username": userStatus["username"]}),
      );
      final favoritesJson = jsonDecode(favoritesResponse.body);
      if (favoritesJson['status'] != 'success' ||
          favoritesJson['favorites'] == null) {
        throw Exception('Failed to load favorites');
      }
      final List<dynamic> favoritesList = favoritesJson['favorites'];
      List<FavoriteCompany> favorites = [];

      // For each favorite (CIK), fetch SEC data and risk score
      for (var cik in favoritesList) {
        // Fetch SEC data
        final secResponse = await http.post(
          Uri.parse(callPythonUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"action": "get_sec_data", "search_term": cik}),
        );
        final secJson = jsonDecode(secResponse.body);
        Map<String, dynamic>? companyData = secJson['company'];

        // Fetch risk score
        final riskResponse = await http.post(
          Uri.parse(callPythonUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"action": "get_company_score", "cik": cik}),
        );
        final riskJson = jsonDecode(riskResponse.body);
        int riskScore =
            (riskJson['status'] == 'success' && riskJson['riskScore'] != null)
                ? riskJson['riskScore']
                : -1;

        favorites.add(FavoriteCompany(
          cik: cik,
          companyData: companyData,
          riskScore: riskScore,
        ));
      }
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

// --- UI for Dashboard Content ---

class DashboardContent extends StatelessWidget {
  final String loggedInUser;
  final VoidCallback logoutCallback;

  const DashboardContent({
    super.key,
    required this.loggedInUser,
    required this.logoutCallback,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.status == DashboardStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.status == DashboardStatus.error) {
          return Center(child: Text('Error: ${state.errorMessage}'));
        } else if (state.status == DashboardStatus.loaded) {
          final userStatus = state.userStatus;
          final favorites = state.favorites;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Text(
                  'Welcome, $loggedInUser!',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Reviewer features, if the user's role is "true"
                if (userStatus != null && userStatus["role"] == "true")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reviewer Features',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Implement special reviewer action here
                        },
                        child: const Text('Special Reviewer Action'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                // Favorites table section
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Header row
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text('',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('Verified',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('Rating',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('Remove',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('QR Code',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const Divider(color: Colors.white),
                      // Favorites list
                      favorites.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: favorites.length,
                              itemBuilder: (context, index) {
                                final fav = favorites[index];
                                final companyName = (fav.companyData != null &&
                                        fav.companyData!['name'] != null)
                                    ? fav.companyData!['name']
                                    : fav.cik;
                                final isVerified = (fav.riskScore >= 0);
                                return ExpansionTile(
                                  title: Text(companyName,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                            child: Text('',
                                                style: TextStyle(
                                                    color: Colors.white))),
                                        Expanded(
                                            child: Text(
                                                isVerified ? "Yes" : "No",
                                                style: const TextStyle(
                                                    color: Colors.white))),
                                        Expanded(
                                            child: Text(
                                                fav.riskScore.toString(),
                                                style: const TextStyle(
                                                    color: Colors.white))),
                                        Expanded(
                                          child: IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.white),
                                            onPressed: () {
                                              // Implement removal of favorite here
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: IconButton(
                                            icon: const Icon(Icons.qr_code,
                                                color: Colors.white),
                                            onPressed: () {
                                              // Implement QR code display here
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              },
                            )
                          : const Text('No favorite companies.',
                              style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: logoutCallback,
                    child: const Text('Log Out'),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
