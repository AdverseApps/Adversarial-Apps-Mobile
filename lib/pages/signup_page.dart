import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../components/shared_app_bar.dart'; // If you want to show your navbar on sign up as well
import 'dashboard_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  List<String> errors = [];
  bool isLoading = false;

  // API endpoints (adjust as needed)
  final String registerUrl = 'https://adversarialapps.com/api/call-python-api';
  final String loginUrl = 'https://adversarialapps.com/api/create-user-session';

  /// Extracts the token from the Set-Cookie header.
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

  /// Validates the password according to criteria.
  List<String> _validatePassword(String password, String confirmPassword) {
    List<String> validationErrors = [];
    if (password != confirmPassword) {
      validationErrors.add("Passwords must match!");
    }
    if (password.length < 8) {
      validationErrors.add("Password must be at least 8 characters long.");
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      validationErrors
          .add("Password must include at least one uppercase letter.");
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      validationErrors.add("Password must include at least one number.");
    }
    if (!RegExp(r'[@$!%*?&]').hasMatch(password)) {
      validationErrors.add(
          "Password must include at least one special character (@\$!%*?&).");
    }
    return validationErrors;
  }

  /// Calls the register API to add the user.
  Future<void> _registerUser(String email, String password) async {
    // Prepare the request payload. Note: we send the password as “password_hashed”
    // as in your React code.
    final Map<String, dynamic> bodyData = {
      "action": "add_user",
      "username": email,
      "password_hashed": password,
      "company": null,
    };

    final response = await http.post(
      Uri.parse(registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyData),
    );

    final result = jsonDecode(response.body);
    if (result['status'] != "success") {
      throw Exception(result['message'] ?? "Registration failed");
    }
  }

  /// Creates a user session by calling the login API.
  Future<void> _createUserSession(String email, String password) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      final result = jsonDecode(response.body);
      throw Exception(result['error'] ?? "Failed to create session");
    }

    final setCookie = response.headers['set-cookie'];
    final authToken = _parseAuthToken(setCookie);
    if (authToken != null) {
      await _storage.write(key: 'auth_token', value: authToken);
    } else {
      throw Exception("No token received");
    }
  }

  /// Handles sign up form submission.
  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate password fields.
    final validationErrors = _validatePassword(password, confirmPassword);
    if (validationErrors.isNotEmpty) {
      setState(() {
        errors = validationErrors;
      });
      return;
    }

    setState(() {
      errors = [];
      isLoading = true;
    });

    try {
      // First, add the user to the database.
      await _registerUser(email, password);
      // Then, create the user session (login).
      await _createUserSession(email, password);
      // Clear sensitive data from memory.
      _passwordController.clear();
      _confirmPasswordController.clear();

      // Navigate to the DashboardPage.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } catch (e) {
      setState(() {
        errors = [e.toString()];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
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
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    if (errors.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.red.shade500,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: errors
                              .map((err) => Text(err,
                                  style: const TextStyle(color: Colors.white)))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _handleSignUp,
                      child: const Text('Sign Up'),
                    ),
                    const SizedBox(height: 16),
                    // Link back to the login page
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DashboardPage()),
                        );
                      },
                      child: const Text("Already have an account? Log In"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
