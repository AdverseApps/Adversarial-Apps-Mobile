import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/report_cubit.dart';

class ReportPage extends StatelessWidget {
  final String cik;

  const ReportPage({Key? key, required this.cik}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<ReportCubit>();

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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Company Details', style: TextStyle(fontSize: 30)),
                  Text('Name: ${details['name']}',
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
                ],
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
