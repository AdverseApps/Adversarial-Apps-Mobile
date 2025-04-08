import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adversarialapps/pages/cubit/dashboard_cubit.dart';

class DashboardContent extends StatelessWidget {
  final String loggedInUser;
  final VoidCallback logoutCallback;

  const DashboardContent({
    Key? key,
    required this.loggedInUser,
    required this.logoutCallback,
  }) : super(key: key);

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
                              child: Text('Company',
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
                                // Get company name based on type.
                                final companyName = fav.source == "SEC"
                                    ? (fav.companyData != null &&
                                            fav.companyData!['name'] != null
                                        ? fav.companyData!['name']
                                        : fav.identifier)
                                    : (fav.companyData != null &&
                                            fav.companyData!['company_name'] != null
                                        ? fav.companyData!['company_name']
                                        : fav.identifier);
                                // Determine if verified.
                                bool isVerified;
                                if (fav.source == "SEC") {
                                  isVerified = fav.riskScore is num && fav.riskScore >= 0;
                                } else {
                                  isVerified = (fav.riskScore == "SAM Compliant");
                                }
                                return ExpansionTile(
                                  title: Text(
                                    companyName,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text(
                                          fav.identifier,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )),
                                        Expanded(
                                            child: Text(
                                          isVerified ? "Yes" : "No",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )),
                                        Expanded(
                                            child: Text(
                                          fav.riskScore.toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )),
                                        Expanded(
                                          child: IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.white),
                                            onPressed: () {
                                              // Implement removal of favorite here.
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: IconButton(
                                            icon: const Icon(Icons.qr_code,
                                                color: Colors.white),
                                            onPressed: () {
                                              // Implement QR code display here.
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
