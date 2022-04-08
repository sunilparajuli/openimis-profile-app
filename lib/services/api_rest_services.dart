import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/models/usp_policy_insuree_hib.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/helper/shared_preferences_helper.dart' as helper;
class ApiRestServices {
  UspPolicyInsureeHib usppolicyhib;

  Future<UspPolicyInsureeHib> UspPolicyHIB(token, args, canrefresh) async {
    try {
      final response = await http.get(Uri.parse("${env.API_HIB_REST_URL}/webapp/get_insuree_details?chfid=${args}"),
          headers: {
            "Content-Type": "application/json",
//                "Accept" : "application/json"
          },

      );
      var jsonMap = json.decode(utf8.decode(response.bodyBytes));
      helper.SessionManager().setprocedureHIB(utf8.decode(response.bodyBytes));
      usppolicyhib = UspPolicyInsureeHib.fromJson(jsonMap);
    } catch (Exception) {
      return usppolicyhib;
    }
    return usppolicyhib;
  }

}