import 'dart:async';
import 'dart:convert';

import 'package:openimis_web_app/models/insuree_claims.dart';
import 'package:openimis_web_app/models/insuree_info.dart';
import 'package:openimis_web_app/models/insuree_policy_information.dart';
import 'package:openimis_web_app/models/policy_information.dart';
import 'package:openimis_web_app/models/usp_policy_insuree_hib.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SessionManager {
  final String fullname = "";
  final String? image_url = null;


  InsureePolicyInformation? _informationpolicy;
  Claims? _claims;
  InsureeData? _insureedata;
  UspPolicyInsureeHib? _uspPolicyInsureeHib;
  PolicyInformation? _policyInformation;
//set data into shared preferences like this
  static const String KEY_FULLNAME = "saved_fullname";
  Future<void> setFullname(String fullname) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_FULLNAME, fullname);
  }

  Future<String> getFullname() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? val = pref.getString(KEY_FULLNAME);
    return val ?? "";
  }

  static const String KEY_IMAGE = "saved_image";
  Future<void>setImage(String image_url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_IMAGE, image_url);
  }

    Future<String> getImage() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? val = pref.getString(KEY_IMAGE);
    return val ?? "";
  }


  Future<void> setUserInfo(String fullname) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(this.fullname, fullname);
  }

  Future<void> setPolicyInformation(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("policyinformation", args);
  }


  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> getInfoStatus() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("policyinformation");
    if(cachedData==null){
      return false;
    }
    return true;
  }
  Future<InsureePolicyInformation?> getPolicyInformation() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("policyinformation");
    if (cachedData == null) return null;
    _informationpolicy = InsureePolicyInformation.fromJson(json.decode(cachedData));
    return _informationpolicy;
  }



  Future<bool> getClaimsServicesStatus() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("ClaimsServicesGQL");
    if(cachedData==null){
      return false;
    }
    return true;
  }

  Future<void> setClaimsServicesGQL(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.clear();
    prefs.setString("ClaimsServicesGQL", args);
  }

  Future<Claims?> getClaimsServicesGQL() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("ClaimsServicesGQL");
    if (cachedData == null) return null;
    _claims = Claims.fromJson(json.decode(cachedData));
    return _claims;
  }

  Future<bool> getInsureeInfoServicesStatus() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("InsureeInfoServicesGQL");
    if(cachedData==null){
      return false;
    }
    return true;
  }

  Future<void> setInsureeInfoServicesGQL(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("InsureeInfoServicesGQL", args);
  }

  Future<InsureeData?> getInsureeInfoServicesGQL() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("InsureeInfoServicesGQL");
    if (cachedData == null) return null;
    _insureedata = InsureeData.fromJson(json.decode(cachedData));
    return _insureedata;
  }


  Future<bool> getprocedureHIBstatus() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("procedureHIB");
    if(cachedData==null){
      return false;
    }
    return true;
  }

  Future<void> setprocedureHIB(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("procedureHIB", args);
  }

  Future<UspPolicyInsureeHib?> getprocedureHIB() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("procedureHIB");
    if (cachedData == null) return null;
    _uspPolicyInsureeHib = UspPolicyInsureeHib.fromJson(json.decode(cachedData));
    return _uspPolicyInsureeHib;
  }


  // Future<bool> getprocedureHIBstatus() async{
  //   final SharedPreferences pref = await SharedPreferences.getInstance();
  //   var cachedData = pref.getString("procedureHIB") ??null;
  //   if(cachedData==null){
  //     return false;
  //   }
  //   return true;
  // }

  Future<void> setPolicyInformationCardPage(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("PolicyInformationCardPage", args);
  }

  Future<PolicyInformation?> getPolicyInformationCardPage() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var cachedData = pref.getString("PolicyInformationCardPage");
    if (cachedData == null) return null;
    _policyInformation = PolicyInformation.fromJson(json.decode(cachedData));
    return _policyInformation;
  }


  Future<void> setRefreshApi(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("refreshApi", args.toString());
  }

  Future<bool> getRefreshApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var exp = prefs.get("refreshApi");
    return exp=="true";

  }

  Future<bool> getTrueSetFalseRefreshAPi() async{
    var isRefresh = await getRefreshApi() .then((value){
      return value;
    });

    if(isRefresh==true){
      Timer.periodic(Duration(milliseconds: 500), (timer)  async{
        await setRefreshApi(false);
        timer.cancel();
      });
    }
    return isRefresh;
  }

  static const String KEY_BIOMETRIC_ENABLED = "biometric_enabled";
  Future<void> setBiometricEnabled(bool enabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_BIOMETRIC_ENABLED, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(KEY_BIOMETRIC_ENABLED) ?? false;
  }
}

