import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'cubit/sam_report_cubit.dart';

class SamReportPage extends StatelessWidget {
  final String uei;
  final String username;

  const SamReportPage({
    Key? key,
    required this.uei,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Trigger fetching the SAM company details (if needed)
    context.read<SamReportCubit>().fetchCompanyDetails(uei);

    return Scaffold(
      appBar: AppBar(title: const Text('SAM Company Details')),
      body: BlocBuilder<SamReportCubit, SamReportState>(
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
            // Extract fields from the SAM data model
            final companyName =
                details['company_name'] ?? 'N/A';
            final address1 =
                details['address_line1'] ?? 'N/A';
            final address2 =
                details['address_line2'] ?? '';
            final city = details['city'] ?? 'N/A';
            final stateOrProvince =
                details['state_or_province'] ?? 'N/A';
            final zipCode = details['zip_code'] ?? 'N/A';
            final countryCode = details['country_code'] ?? 'N/A';
            final registrationDate =
                details['registration_date'] ?? 'N/A';
            final expirationDate =
                details['expiration_date'] ?? 'N/A';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Company Details',
                        style: TextStyle(fontSize: 30)),
                    Text('Legal Business Name: $companyName',
                        style: const TextStyle(fontSize: 16)),
                    Text('Address Line 1: $address1',
                        style: const TextStyle(fontSize: 16)),
                    if (address2.isNotEmpty)
                      Text('Address Line 2: $address2',
                          style: const TextStyle(fontSize: 16)),
                    Text('City: $city',
                        style: const TextStyle(fontSize: 16)),
                    Text('State/Province: $stateOrProvince',
                        style: const TextStyle(fontSize: 16)),
                    Text('Zip Code: $zipCode',
                        style: const TextStyle(fontSize: 16)),
                    Text('Country Code: $countryCode',
                        style: const TextStyle(fontSize: 16)),
                    Text('Registration Date: $registrationDate',
                        style: const TextStyle(fontSize: 16)),
                    Text('Expiration Date: $expirationDate',
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
                          data: 'https://adversarialapps.com/company/sam/$uei',
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
                              .read<SamReportCubit>()
                              .toggleFavorite(username, uei);
                          // Optionally show a SnackBar with confirmation
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
