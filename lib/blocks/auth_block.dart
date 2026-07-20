import 'package:flutter/material.dart';
import 'package:openimis_web_app/models/user.dart';
import 'package:openimis_web_app/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openimis_web_app/helper/shared_preferences_helper.dart';

class AuthBlock extends ChangeNotifier {
  final storage = FlutterSecureStorage();
  AuthBlock() {
    setUser();
  }
  AuthService _authService = AuthService();
  // Index
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }


//getters for token expiry checker
  bool isTokenExpired = false;
  bool get tokenExpired => isTokenExpired;
  set tokenExpired(bool check){
    isTokenExpired = check;
    notifyListeners();
  }

  // Loading
  bool _loading = false;
  String _loadingType = '';
  bool get loading => _loading;
  String get loadingType => _loadingType;
  set loading(bool loadingState) {
    _loading = loadingState;
    notifyListeners();
  }
  set loadingType(String loadingType) {
    _loadingType = loadingType;
    notifyListeners();
  }
  // Loading
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool isUserExist) {
    _isLoggedIn = isUserExist;
    notifyListeners();
  }

  bool _isRegisterSuccess = false;
  bool get isRegisterSuccess => _isRegisterSuccess;

  // user
  Map _user = {};
  Map get user => _user;
  setUser() async {
    try {
      var u = await _authService.getUser();
      bool sessionActive = await SessionManager().isSessionActive();
      _user = u ?? {};
      isLoggedIn = u != null && sessionActive;
    } catch (e) {
      print("Error retrieving user session: $e");
      _user = {};
      isLoggedIn = false;
      await logout();
    }
    notifyListeners();
  }

  login(UserCredential userCredential) async {
    loading = true;
    loadingType = 'login';
    await _authService.login(userCredential);
    await SessionManager().setSessionActive(true); // Set session active after OTP success
    setUser();
    loading = false;
    notifyListeners();
  }



  register(UserRegister userRegister) async {
    loading = true;
    loadingType = 'register';
    var a = await _authService.register(userRegister);
    if (a == null) {
      loading = false;
    } else {
      _isRegisterSuccess = true;
    }
    notifyListeners();

  }


    validateOtp(UserRegister userRegister) async {
    loading = true;
    loadingType = 'register';
    var a = await _authService.register(userRegister);
    if (a == null) {
      loading = false;
    } else {
      _isRegisterSuccess = true;
    }
    notifyListeners();

  }

  logout() async {
    isLoggedIn = false;
    _currentIndex = 0; // Reset index to homepage
    
    bool bioEnabled = await SessionManager().isBiometricEnabled();
    await SessionManager().setSessionActive(false); // Mark session as inactive

    if (!bioEnabled) {
      // FULL WIPE only if biometrics are NOT enabled
      await _authService.logout();
      await storage.deleteAll();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    } else {
      // Partial clear: keep the 'user' data in storage for biometric "unlocking"
      // but clear the SharedPreferences cache
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final keysToKeep = [SessionManager.KEY_BIOMETRIC_ENABLED, SessionManager.KEY_SESSION_ACTIVE];
      final Map<String, dynamic> savedValues = {};
      
      for (String key in keysToKeep) {
        if (preferences.containsKey(key)) {
          savedValues[key] = preferences.get(key);
        }
      }
      
      await preferences.clear();
      
      // Restore the kept settings
      for (String key in savedValues.keys) {
        if (savedValues[key] is bool) await preferences.setBool(key, savedValues[key]);
      }
    }

    notifyListeners();
  }
}
