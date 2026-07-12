// import 'package:openimis_web_app/blocks/auth_block.dart';

import 'dart:async';
import 'package:openimis_web_app/models/usp_policy_insuree_hib.dart';
import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:openimis_web_app/services/api_client.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/helper/shared_preferences_helper.dart' as helper;
class ApiRestServices {
  UspPolicyInsureeHib? usppolicyhib;
//   AppConfig _appConfig;
  Future<UspPolicyInsureeHib> UspPolicyHIB(String token, String chfId, bool canRefresh) async {
      try {
        final response = await ApiClient.getRestFullUrl(
            "${env.API_HIB_REST_URL}/webapp/get_insuree_details?chfid=${chfId}",
            token: token,
        );
        var jsonMap = json.decode(utf8.decode(response.bodyBytes));
        helper.SessionManager().setprocedureHIB(
            utf8.decode(response.bodyBytes));
        usppolicyhib = UspPolicyInsureeHib.fromJson(jsonMap);
      } catch (e) {
        if (usppolicyhib != null) return usppolicyhib!;
        throw Exception("API Error");
      }
      return usppolicyhib!;

  }


  // Future<AppConfig> GetAppConfig(token) async {
  //   try {
  //     final response = await http.get(Uri.parse(
  //         "${env.API_HIB_REST_URL}/webapp/get_insuree_details?chfid=${args}"),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Insuree-Token" : "${token}"
  //       },
  //
  //     );
  //     var jsonMap = json.decode(utf8.decode(response.bodyBytes));
  //     helper.SessionManager().setprocedureHIB(
  //         utf8.decode(response.bodyBytes));
  //     usppolicyhib = UspPolicyInsureeHib.fromJson(jsonMap);
  //   } catch (Exception) {
  //     return usppolicyhib;
  //   }
  //   return usppolicyhib;
  //
  // }

}