import 'package:adversarialapps/services/cik_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/shared_app_bar.dart';
import 'cubit/search_cubit.dart';
import 'cubit/report_cubit.dart';
import 'report_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchCubit = context.read<SearchCubit>();

    return Scaffold(
      appBar: const SharedAppBar(title: 'Search CIK'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Enter Company Name',
                hintText: 'e.g., Apple',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Call cubit search on each change
                searchCubit.search(value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
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
                  } else if (state.results.isEmpty) {
                    return const Center(child: Text('No results.'));
                  } else {
                    return ListView.builder(
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        final company = state.results[index];
                        return ListTile(
                          title: Text(company.name),
                          subtitle: Text('CIK: ${company.cik}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (_) => ReportCubit(CikService())
                                    ..fetchCompanyDetails(company.cik),
                                  child: ReportPage(cik: company.cik),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
