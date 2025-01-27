import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/shared_app_bar.dart';
import 'cubit/search_cubit.dart';

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
            // SEARCH INPUT
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Enter Company Name',
                hintText: 'e.g., Apple',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Call cubit search on each change (or implement a debounce if you prefer)
                searchCubit.search(value);
              },
            ),
            const SizedBox(height: 16),

            // RESULTS
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
                            // For example, show a SnackBar or navigate
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Selected ${company.name} (CIK: ${company.cik})',
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
