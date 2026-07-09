import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:openimis_web_app/common/env.dart' as env;

class ApiClient {
  static Future<http.Response> postGraphQL(String token, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse(env.API_BASE_URL),
      headers: {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Insuree-Token": token,
        "App-Version": env.APP_VERSION,
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> getRestFullUrl(String fullUrl, {String token}) async {
    return await http.get(
      Uri.parse(fullUrl),
      headers: {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Insuree-Token": token,
        "App-Version": env.APP_VERSION,
      },
    );
  }
}
