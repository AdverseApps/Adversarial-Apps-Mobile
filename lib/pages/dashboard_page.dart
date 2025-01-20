import 'package:flutter/material.dart';
import '../components/shared_app_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // You can add form controllers here:
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoggedIn = false;

  void _attemptLogin() {
    // Simple validation or mock login logic:
    final username = _usernameController.text;
    final password = _passwordController.text;

    // In real code, you'd probably use a service or make an API call.
    if (username.isNotEmpty && password.isNotEmpty) {
      setState(() {
        isLoggedIn = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SharedAppBar(title: 'Dashboard'),
      body: Center(
        child: Text('Dashboard content / login form here'),
      ),
    );
  }
}
