import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Instance to securely store the auth token
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Controllers for the login form
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // UI state variables
  bool isLoggedIn = false;
  bool isLoading = false;
  String loggedInUser = "";

  // API endpoints (update these as necessary)
  final String loginUrl = 'https://adversarialapps.com/api/create-user-session';
  // This endpoint should verify the token. It corresponds to your Next.js GET endpoints
  final String verifyUrl = 'https://adversarialapps.com/api/verify-token';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// Checks if a token is already stored and then verifies it with the API.
  Future<void> _checkLoginStatus() async {
    setState(() {
      isLoading = true;
    });
    String? token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        // Send a GET request including the token in the Cookie header.
        final response = await http.get(
          Uri.parse(verifyUrl),
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'auth_token=$token'
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
            // Token is invalid—remove it
            await _storage.delete(key: 'auth_token');
            setState(() => isLoggedIn = false);
          }
        } else {
          // Response not OK—assume token is no longer valid
          await _storage.delete(key: 'auth_token');
          setState(() => isLoggedIn = false);
        }
      } catch (e) {
        // On error, remove token and show login form
        await _storage.delete(key: 'auth_token');
        setState(() => isLoggedIn = false);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  /// Extracts the auth token from the Set-Cookie header.
  /// Expected header format:
  ///   "auth_token=eyJ...; HttpOnly; Path=/; Max-Age=43200; Secure; SameSite=Strict"
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

  /// Attempts to log in the user by calling the login API.
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
        // Look for the Set-Cookie header containing the JWT
        final setCookie = response.headers['set-cookie'];
        final authToken = _parseAuthToken(setCookie);
        if (authToken != null) {
          // Store the token securely
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
        // Login failed—display the error message from the API
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
    // Optionally, you can also call your API logout endpoint here.
    await _storage.delete(key: 'auth_token');
    setState(() {
      isLoggedIn = false;
      loggedInUser = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: isLoggedIn
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Log out',
                )
              ]
            : null,
      ),
      body: Center(
        child: isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, $loggedInUser',
                    style: const TextStyle(fontSize: 20),
                  ),
                  // Insert additional dashboard content here
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
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
