import 'package:flutter/material.dart';
import '../components/shared_app_bar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SharedAppBar(title: 'Search'),
      body: Center(
        child: Text('Search Page'),
      ),
    );
  }
}
