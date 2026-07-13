import 'dart:async';
import 'dart:convert';
import 'package:openimis_web_app/models/insuree.dart';
import 'package:openimis_web_app/services/api_client.dart';

class VerifyInsureeService {
  bool isLoading = false;

  Future<Map<String, dynamic>> VerifyInsureeData(Insuree verifyInsuree) async {
    isLoading = true;
    var body = {
      "query": "\n\nquery {\n "
          " insureeAuth(insureeCHFID: \"${verifyInsuree.chfid.toString()}\", familyHeadCHFID: \""
          "${verifyInsuree.fhchfid.toString()}\", dob:\"${verifyInsuree.dob}\"){\n    id\n message\n issuccess\n  }\n}"
    };
    
    final response = await ApiClient.postGraphQL('', body);

    print(response.body);
    isLoading = false;
    
    return json.decode(response.body);
  }
}
