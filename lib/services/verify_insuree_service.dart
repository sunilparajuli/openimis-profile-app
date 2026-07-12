import 'dart:async';
import 'dart:convert';
import 'package:openimis_web_app/models/insuree.dart';
import 'package:http/http.dart' as http;
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/services/api_client.dart';

class VerifyInsureeService {
bool isLoading=false;

  Future<Map> VerifyInsureeData(Insuree _verifyInsuree) async {
    isLoading = true;
    var body = {"query":"\n\nquery {\n "
        " insureeAuth(insureeCHFID: \"${_verifyInsuree.chfid.toString()}\", familyHeadCHFID: \""
        "${_verifyInsuree.fhchfid.toString()}\", dob:\"${_verifyInsuree.dob}\"){\n    id\n message\n issuccess\n  }\n}"};
    //body = {"query":"\n\nquery {\n  insureeAuth(insureeCHFID: \"100\", familyHeadCHFID: \"200\", dob:\"1952-05-07\"){\n    id\n  }\n}\n","variables":null};
    final response = await ApiClient.postGraphQL('', body);

    print(response.body);
//     var responseBody = response.body;
      isLoading=false;
      var responseData = jsonDecode(response.body);
      //return responseData['data']['insureeAuth']; //{\"data\":{\"insureeAuth\":{\"id\":\"1\",\"message\":\"Phone number not found.Please contact HIB\"}}}
    return responseData;
    }

  }



