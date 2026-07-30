import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:openimis_web_app/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/graphql/gql_queries.dart';
import 'package:openimis_web_app/helper/shared_preferences_helper.dart' as helper;
import 'package:openimis_web_app/utils/toast_helper.dart';

import 'package:openimis_web_app/services/api_client.dart';

class AuthService {
  late AuthBlock auth;
  
  final storage = const FlutterSecureStorage(
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<Map> login(UserCredential userCredential) async {
    // Clear any previous session data before starting a new login process
    await helper.SessionManager().clearAll();

    var query = OpenimisGqlQueries.otpVerify({
      "chfid": "${userCredential.chfid}", 
      "otp": "${userCredential.otp}" 
    });
    
    final response = await ApiClient.postGraphQL('', query);

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      
      if (responseData['data']['insureeAuthOtp'] == null) {
        ToastHelper.showToast(
            msg: "Incorrect OTP Details. Please try again.",
            gravity: ToastGravity.CENTER,
            fontSize: 16.0);
        throw Exception("Invalid OTP");
      }

      setUser(response.body);
      ToastHelper.showToast(
          msg: "Login success",
          gravity: ToastGravity.CENTER,
          fontSize: 16.0);
      return responseData;
    } else {
      ToastHelper.showToast(
          msg: "Server Error",
          gravity: ToastGravity.CENTER,
          fontSize: 16.0);
    }
    throw Exception("Authentication Failed");
  }

  Future<void> setUser(String value) async {
    await storage.write(key: 'user', value: value);
  }

  Future<Map?> getUser() async {
    String? user = await storage.read(key: 'user');
    if (user != null && user.isNotEmpty) {
      return jsonDecode(user);
    }
    return null;
  }

  Future<void> logout() async {
    await storage.delete(key: 'user');
  }
}
