import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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
      _token = body['idToken'];
      _userId = body['localId'];
      _expireDate = DateTime.now().add(Duration(seconds: int.parse(body['expiresIn'])));
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expireDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAuthLogin () async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final data = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expireDate = DateTime.parse(data['expiryDate']);

    if (expireDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = data['token'];
    _userId = data['userId'];
    _expireDate = expireDate;
    notifyListeners();
    _autoLogout();
    return true;
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
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expireDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }

    _autoLogout();
  }

  String get userId {
    return this._userId;
  }

  Future<void> logOut() async {
    _expireDate = null;
    _userId = null;
    _token = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
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