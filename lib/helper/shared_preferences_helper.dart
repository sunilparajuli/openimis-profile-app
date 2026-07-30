import 'dart:async';
import 'dart:convert';

import 'package:openimis_web_app/models/insuree_claims.dart';
import 'package:openimis_web_app/models/insuree_info.dart';
import 'package:openimis_web_app/models/insuree_policy_information.dart';
import 'package:openimis_web_app/models/policy_information.dart';
import 'package:openimis_web_app/models/usp_policy_insuree_hib.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String KEY_FULLNAME = "saved_fullname";
  static const String KEY_IMAGE = "saved_image";
  static const String KEY_BASE64_IMAGE = "saved_base64_image";
  static const String KEY_BIOMETRIC_ENABLED = "biometric_enabled";
  static const String KEY_SESSION_ACTIVE = "session_active";

  Future<void> setFullname(String fullname) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_FULLNAME, fullname);
  }

  Future<String> getFullname() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(KEY_FULLNAME) ?? "";
  }

  Future<void> setImage(String image_url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_IMAGE, image_url);
  }

  Future<String> getImage() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(KEY_IMAGE) ?? "";
  }

  Future<void> settBase64Image(String base64String) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_BASE64_IMAGE, base64String);
  }

  Future<String?> getBase64Image() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(KEY_BASE64_IMAGE);
  }

  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> getInfoStatus() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("policyinformation") != null;
  }

  Future<void> setPolicyInformation(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("policyinformation", args);
  }

  Future<InsureePolicyInformation?> getPolicyInformation() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("policyinformation");
    if (cachedData == null) return null;
    return InsureePolicyInformation.fromJson(json.decode(cachedData));
  }

  Future<bool> getClaimsServicesStatus() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("ClaimsServicesGQL") != null;
  }

  Future<void> setClaimsServicesGQL(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("ClaimsServicesGQL", args);
  }

  Future<Claims?> getClaimsServicesGQL() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("ClaimsServicesGQL");
    if (cachedData == null) return null;
    return Claims.fromJson(json.decode(cachedData));
  }

  Future<bool> getInsureeInfoServicesStatus() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("InsureeInfoServicesGQL") != null;
  }

  Future<void> setInsureeInfoServicesGQL(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("InsureeInfoServicesGQL", args);
  }

  Future<InsureeData?> getInsureeInfoServicesGQL() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("InsureeInfoServicesGQL");
    if (cachedData == null) return null;
    return InsureeData.fromJson(json.decode(cachedData));
  }

  Future<bool> getprocedureHIBstatus() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("procedureHIB") != null;
  }

  Future<void> setprocedureHIB(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("procedureHIB", args);
  }

  Future<UspPolicyInsureeHib?> getprocedureHIB() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("procedureHIB");
    if (cachedData == null) return null;
    return UspPolicyInsureeHib.fromJson(json.decode(cachedData));
  }

  Future<void> setPolicyInformationCardPage(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PolicyInformationCardPage", args);
  }

  Future<PolicyInformation?> getPolicyInformationCardPage() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("PolicyInformationCardPage");
    if (cachedData == null) return null;
    return PolicyInformation.fromJson(json.decode(cachedData));
  }

  Future<void> setRefreshApi(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("refreshApi", args.toString());
  }

  Future<bool> getRefreshApi() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("refreshApi") == "true";
  }

  Future<bool> getTrueSetFalseRefreshAPi() async {
    var isRefresh = await getRefreshApi();
    if (isRefresh == true) {
      Timer(Duration(milliseconds: 500), () async {
        await setRefreshApi(false);
      });
    }
    return isRefresh;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_BIOMETRIC_ENABLED, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(KEY_BIOMETRIC_ENABLED) ?? false;
  }

  Future<void> setSessionActive(bool active) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_SESSION_ACTIVE, active);
  }

  Future<bool> isSessionActive() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(KEY_SESSION_ACTIVE) ?? false;
  }
}
