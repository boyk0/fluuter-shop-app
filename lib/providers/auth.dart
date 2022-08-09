import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expireDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expireDate != null && _expireDate.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> signUp(String email, String password) async {
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAZFnWOBNE2mJTkIAOWTEL2dDiBAA4_jmQ');
    try {
      final response = await http.post(url, body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }));
      if (response.statusCode != 200) {
        throw Exception('Sign up is not success');
      }
      final body = json.decode(response.body);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAZFnWOBNE2mJTkIAOWTEL2dDiBAA4_jmQ');
      final response = await http.post(url, body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }));
      if (response.statusCode != 200) {
        throw Exception('Log in is not success');
      }
      final body = json.decode(response.body);
      _token = body['idToken'];
      _userId = body['localId'];
      _expireDate = DateTime.now().add(Duration(seconds: int.parse(body['expiresIn'])));
      notifyListeners();
    } catch (error) {
      throw error;
    }

    _autoLogout();
  }

  String get userId {
    return this._userId;
  }

  void logOut() {
    _expireDate = null;
    _userId = null;
    _token = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }

    final timeToExpiry = _expireDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(
      Duration(seconds: timeToExpiry),
      logOut
    );
  }
}