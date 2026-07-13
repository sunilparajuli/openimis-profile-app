import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:openimis_web_app/blocks/auth_block.dart';
import  'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/graphql/gql_queries.dart';
import 'package:openimis_web_app/helper/shared_preferences_helper.dart' as helper;

import 'package:openimis_web_app/services/api_client.dart';

class AuthService {

  late AuthBlock auth;
  final storage = FlutterSecureStorage();
  // Create storage
  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
  Future<Map> login(UserCredential userCredential) async {
    // Clear any previous session data before starting a new login process
    await helper.SessionManager().clearAll();

    var q = OpenimisGqlQueries.otpVerify({"chfid":"${userCredential.chfid}", "otp": "${userCredential.otp}" });
    final response = await ApiClient.postGraphQL('', q);
    print(jsonDecode(response.body));


    if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['data']['insureeAuthOtp']==null)
          {
            Fluttertoast.showToast(
                msg: "Incorrect OTP Details Pls try again ",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);
            throw Exception("Not implemented");
          }

      setUser(response.body);
      Fluttertoast.showToast(
          msg: "Login success",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      return responseData;
    }
    else{
      Fluttertoast.showToast(
          msg: "Server Error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    }
    throw Exception("Not implemented");
  }

  Future<Map> register(UserRegister userRegister) async {
    //String abcd = user.password;
    // user.isRegisterSuccess =false;
    env.setRegisterSuccessFalse();
    
    // Using ApiClient to ensure Token and App-Version are sent
    final response = await ApiClient.postRest("${env.API_HIB_REST_URL}register", {
      'mobile': userRegister.mobile,
      'email': userRegister.email,
      'password': userRegister.password,
      'firstname': userRegister.firstname,
      'lastname': userRegister.lastname
    });

    if (response.statusCode == 200) {
      env.setRegisterSuccessTrue();

      // If the call to the server was successful, parse the JSON.
      Fluttertoast.showToast(
          msg: 'Account Created',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
        var u = jsonDecode(response.body);
         u['isRegisterSuccess'] = true;
        return u;
    } else {
      if (response.statusCode == 400) {
        //  auth.loading = false;
        Fluttertoast.showToast(
            msg: response.body,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      else if (response.statusCode == 500) {
        //  auth.loading = false;
        Fluttertoast.showToast(
            msg: 'Server Error',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      else {
        // auth.loading = false;
         Fluttertoast.showToast(
            msg: 'Server Error',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
          throw Exception("Not implemented");
      }
      // If that call was not successful, throw an error.
//      throw Exception(response.body);

      throw Exception("Not implemented");
    }
  }

  setUser(String value) async {
    await storage.write(key: 'user', value: value);
  }

  getUser() async {
    String? user = await storage.read(key: 'user');
    if (user != null && user.isNotEmpty) {
      return jsonDecode(user);
    }
    return null;
  }
  logout() async {
    await storage.delete(key: 'user');

  }


}
