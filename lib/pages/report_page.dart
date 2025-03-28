import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'cubit/report_cubit.dart';

class ReportPage extends StatelessWidget {
  final String cik;
  final String username;

  const ReportPage({
    super.key,
    required this.cik,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    // Trigger fetching the company details (if needed)
    context.read<ReportCubit>().fetchCompanyDetails(cik);

    return Scaffold(
      appBar: AppBar(title: const Text('Company Details')),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.error != null) {
            return Center(
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state.companyDetails != null) {
            final details = state.companyDetails!;
            final companyName = details['name'] ?? 'N/A';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Company Details',
                        style: TextStyle(fontSize: 30)),
                    Text('Name: $companyName',
                        style: const TextStyle(fontSize: 16)),
                    Text('Business Address: ${details['address']}',
                        style: const TextStyle(fontSize: 16)),
                    Text(
                        'State of Incorporation: ${details['stateOrCountryDescription']}',
                        style: const TextStyle(fontSize: 16)),
                    Text(
                        'State of Incorporation: ${details['stateOfIncorporation']}',
                        style: const TextStyle(fontSize: 16)),
                    Text(
                        'Date of Last Filing: ${details['mostRecentFilingDate']}',
                        style: const TextStyle(fontSize: 16)),
                    Text('Phone: ${details['phone']}',
                        style: const TextStyle(fontSize: 16)),
                    Text('Website: ${details['website']}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    const Text('Company QR Code:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: QrImageView(
                          data: 'https://adversarialapps.com/company/$cik',
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Call the cubit's method to toggle favorite
                          await context
                              .read<ReportCubit>()
                              .toggleFavorite(username, cik);
                          // Optionally show a SnackBar with a confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Favorite toggled.'),
                            ),
                          );
                        },
                        child: const Text('Add to Favorite'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
