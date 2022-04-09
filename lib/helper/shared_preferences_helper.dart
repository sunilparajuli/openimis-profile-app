import 'dart:async';
import 'dart:convert';

import 'package:openimis_web_app/models/insuree_claims.dart';
import 'package:openimis_web_app/models/insuree_info.dart';
import 'package:openimis_web_app/models/insuree_policy_information.dart';
import 'package:openimis_web_app/models/policy_information.dart';
import 'package:openimis_web_app/models/usp_policy_insuree_hib.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//class SessionManager {
//  final String auth_token = "auth_token";
//
////set data into shared preferences like this
//  Future<void> setAuthToken(String auth_token) async {
//    final SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setString(this.auth_token, auth_token);
//  }
//
////get value from shared preferences
//  Future<String> getAuthToken() async {
//    final SharedPreferences pref = await SharedPreferences.getInstance();
//    String auth_token;
//    auth_token = pref.getString(this.auth_token) ?? null;
//    return auth_token;
//  }
//}


class SessionManager {
  final String fullname = "";
  final String image_url = null;


  InsureePolicyInformation _informationpolicy;
  Claims _claims;
  InsureeData _insureedata;
  UspPolicyInsureeHib _uspPolicyInsureeHib;
  PolicyInformation _policyInformation;
//set data into shared preferences like this
  Future<void> setFullname(String fullname) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(this.fullname, fullname);
  }

//get value from shared preferences
  Future<String> getFullname() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String fullname;
    fullname = pref.getString(this.fullname) ?? "";
    return fullname;
  }

  Future<String>setImage(String image_url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(this.image_url, image_url);
  }

    Future<String> getImage() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String image_url;
    image_url = pref.getString(this.image_url) ?? "";
    return image_url;
  }


  Future<void> setUserInfo(String fullname) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(this.fullname, fullname);
  }

  Future<String> setPolicyInformation(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("policyinformation", args);
  }


  Future<String> deletePoicyInfrmatin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> getInfoStatus() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var jpt = pref.getString("policyinformation") ??null;
    if(jpt==null){
      return false;
    }
    return true;
  }
  Future<InsureePolicyInformation> getPolicyInformation() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var jpt = pref.getString("policyinformation") ??null;
    _informationpolicy = InsureePolicyInformation.fromJson(json.decode(jpt));
    return _informationpolicy;

  }



  Future<bool> getClaimsServicesStatus() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var jpt = pref.getString("ClaimsServicesGQL") ??null;
    if(jpt==null){
      return false;
    }
    return true;
  }

  Future<String> setClaimsServicesGQL(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.clear();
    prefs.setString("ClaimsServicesGQL", args);
  }

  Future<Claims> getClaimsServicesGQL() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var jpt = pref.getString("ClaimsServicesGQL") ??null;
    if(jpt==null){
      return null;
    }
    _claims = Claims.fromJson(json.decode(jpt));
    return _claims;

  }

  Future<bool> getInsureeInfoServicesStatus() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var jpt = pref.getString("InsureeInfoServicesGQL") ??null;
    if(jpt==null){
      return false;
    }
    return true;
  }

  Future<String> setInsureeInfoServicesGQL(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("InsureeInfoServicesGQL", args);
  }

  Future<InsureeData> getInsureeInfoServicesGQL() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var jpt = pref.getString("InsureeInfoServicesGQL") ??null;
    if(jpt==null){
      return null;
    }
    _insureedata = InsureeData.fromJson(json.decode(jpt));
    return _insureedata;

  }


  Future<bool> getprocedureHIBstatus() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var jpt = pref.getString("procedureHIB") ??null;
    if(jpt==null){
      return false;
    }
    return true;
  }

  Future<String> setprocedureHIB(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("procedureHIB", args);
  }

  Future<UspPolicyInsureeHib> getprocedureHIB() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var jpt = pref.getString("procedureHIB") ??null;
    _uspPolicyInsureeHib = UspPolicyInsureeHib.fromJson(json.decode(jpt));
    return _uspPolicyInsureeHib;

  }


  // Future<bool> getprocedureHIBstatus() async{
  //   final SharedPreferences pref = await SharedPreferences.getInstance();
  //   var jpt = pref.getString("procedureHIB") ??null;
  //   if(jpt==null){
  //     return false;
  //   }
  //   return true;
  // }

  Future<String> setPolicyInformationCardPage(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("PolicyInformationCardPage", args);
  }

  Future<PolicyInformation> getPolicyInformationCardPage() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var jpt = pref.getString("PolicyInformationCardPage") ??null;
    if(jpt==null){
      return null;
    }
    _policyInformation = PolicyInformation.fromJson(json.decode(jpt));
    return _policyInformation;

  }


  Future<bool> setRefreshApi(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("refreshApi", args.toString());
  }

  Future<bool> getRefreshApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var exp = prefs.get("refreshApi");
    return exp=="true";

  }

  Future<bool> getTrueSetFalseRefreshAPi() async{
    var isRefresh = await getRefreshApi().then((value){
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


}

