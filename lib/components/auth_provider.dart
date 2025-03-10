import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;

  void setLoggedIn(bool loggedIn, {String username = ''}) {
    _isLoggedIn = loggedIn;
    if (username.isNotEmpty) {
      _username = username;
    }
    notifyListeners();
  }
}
