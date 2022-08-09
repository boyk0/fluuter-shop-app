import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expireDate;
  String _userId;

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
      print(body);
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
      print(body);
    } catch (error) {
      throw error;
    }
  }
}