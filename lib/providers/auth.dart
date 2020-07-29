import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  //String _userId;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String username, String urlSegment) async {
    final urlback = 'https://time-set.herokuapp.com/api/auth/$urlSegment';
    final loginJson =
        json.encode({'usernameOrEmail': email, 'password': password});
    final registerJson = json
        .encode({"email": email, "password": password, "username": username});
    try {
      final response = await http.post(
        urlback,
        body: urlSegment == 'signin' ? loginJson : registerJson,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );
      final responseData = json.decode(response.body);
      print(responseData['accessToken']);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['accessToken'];
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password, String username) async {
    return _authenticate(email, password, username, 'signup');
  }

  Future<void> login(String email, String password, String username) async {
    return _authenticate(email, password, username, 'signin');
  }
}
