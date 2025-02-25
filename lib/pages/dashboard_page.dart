import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../components/shared_app_bar.dart';
import 'signup_page.dart'; // Navigation to the sign-up page

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Secure storage instance for storing the JWT
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Controllers for login form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoggedIn = false;
  bool isLoading = false;
  String loggedInUser = "";

  // This endpoint is for the login (hit off of Heroku Server)
  final String loginUrl = 'https://adversarialapps.com/api/create-user-session';
  // This endpoint should verify the token
  final String verifyUrl = 'https://adversarialapps.com/api/verify-token';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// Checks if a token is stored and verifies it with the API.
  Future<void> _checkLoginStatus() async {
    setState(() {
      isLoading = true;
    });
    String? token = await _storage.read(key: 'auth_token');
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
    setState(() {
      isLoading = false;
    });
  }

  /// Helper to extract the auth token from the Set-Cookie header.
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

  /// Logs out the user by clearing the stored token.
  Future<void> _logout() async {
    await _storage.delete(key: 'auth_token');
    setState(() {
      isLoggedIn = false;
      loggedInUser = "";
    });
  }

  /// Returns an appropriate AppBar.
  PreferredSizeWidget _buildAppBar() {
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
      body: Center(
        child: isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, $loggedInUser',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  // Dashboard content goes here
                  const Text('This is your dashboard content.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text('Log Out'),
                  ),
                ],
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
                      // Navigation link to the Sign-Up page
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpPage()),
                          );
                        },
                        child: const Text("Don't have an account? Sign Up"),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
