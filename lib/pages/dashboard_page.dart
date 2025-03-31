import 'dart:convert';
import 'package:adversarialapps/components/auth_provider.dart';
import 'package:adversarialapps/pages/cubit/dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../components/shared_app_bar.dart';
import 'signup_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Secure storage to hold the JWT
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Login form controllers (shown when not logged in)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoggedIn = false;
  bool isLoading = false;
  String loggedInUser = "";
  String? _authToken;

  // API endpoints (adjust if needed)
  final String loginUrl = 'https://adversarialapps.com/api/create-user-session';
  final String verifyUrl = 'https://adversarialapps.com/api/verify-token';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (isLoggedIn) {
      Provider.of<AuthProvider>(context, listen: false)
          .setLoggedIn(true, username: loggedInUser);
    }
  });
    _checkLoginStatus();
  }

  /// Verifies whether a token exists and is valid.
  Future<void> _checkLoginStatus() async {
    setState(() => isLoading = true);
    String? token;
    try {
      token = await _storage.read(key: 'auth_token');
    } catch (e) {
      // Error reading token: remove the invalid token.
      await _storage.delete(key: 'auth_token');
      token = null;
    }

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse(verifyUrl),
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'auth_token=$token',
          },
        );
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true && responseData['user'] != null) {
            setState(() {
              isLoggedIn = true;
              loggedInUser = responseData['user'];
              _authToken = token;
            });
          } else {
            await _storage.delete(key: 'auth_token');
            setState(() => isLoggedIn = false);
          }
        } else {
          await _storage.delete(key: 'auth_token');
          setState(() => isLoggedIn = false);
        }
      } catch (e) {
        await _storage.delete(key: 'auth_token');
        setState(() => isLoggedIn = false);
      }
    }
    setState(() => isLoading = false);
  }

  /// Extracts the auth token from a Set-Cookie header.
  String? _parseAuthToken(String? setCookieHeader) {
    if (setCookieHeader == null) return null;
    final parts = setCookieHeader.split(';');
    if (parts.isNotEmpty) {
      final tokenPair = parts[0].split('=');
      if (tokenPair.length == 2) {
        return tokenPair[1].trim();
      }
    }
    return null;
  }

  /// Attempts to log in the user.
  Future<void> _attemptLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter both username and password.')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final setCookie = response.headers['set-cookie'];
        final authToken = _parseAuthToken(setCookie);
        if (authToken != null) {
          await _storage.write(key: 'auth_token', value: authToken);
          setState(() {
            isLoggedIn = true;
            loggedInUser = username;
            _authToken = authToken;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed: No token received.')),
          );
        }
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['error'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during login: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Logs out by clearing the stored token.
  Future<void> _logout() async {
    Provider.of<AuthProvider>(context, listen: false).setLoggedIn(false);
    await _storage.delete(key: 'auth_token');
    setState(() {
      isLoggedIn = false;
      loggedInUser = "";
      _authToken = null;
    });
  }

  /// Returns an appropriate AppBar.
  PreferredSizeWidget _buildAppBar() {
    // When logged in, use your existing SharedAppBar (with navigation links)
    if (isLoggedIn) {
      return const SharedAppBar(title: 'Dashboard');
    }
    return AppBar(title: const Text('Login'));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoggedIn
          ? BlocProvider(
              create: (_) =>
                  DashboardCubit(authToken: _authToken!)..fetchDashboardData(),
              child: DashboardContent(
                loggedInUser: loggedInUser,
                logoutCallback: _logout,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _attemptLogin,
                      child: const Text('Log In'),
                    ),
                    const SizedBox(height: 16),
                    // Link to the sign-up page
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: const Text("Don't have an account? Sign Up"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
