import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:openimis_web_app/common/env.dart' as env;

class ApiClient {
  static Future<http.Response> postGraphQL(String token, Map<String, dynamic> body) async {
    final uri = Uri.parse(env.API_BASE_URL);
    final headers = {
      "Content-Type": "application/json",
      if (token.isNotEmpty) "Insuree-Token": token,
      "App-Version": env.APP_VERSION,
    };

    // DEBUG LOG
    if (!env.production) {
      print("--- GRAPHQL REQUEST ---");
      print("URL: $uri");
      print("Headers: $headers");
      print("Body: ${jsonEncode(body)}");
    }

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    // DEBUG LOG RESPONSE
    if (!env.production) {
      print("--- RESPONSE (${response.statusCode}) ---");
      print("Body: ${response.body}");
    }

    return response;
  }


  static Future<http.Response> postRest(String url, Map<String, dynamic> body, {String token = ''}) async {
    final headers = {
      "Content-Type": "application/json",
      if (token.isNotEmpty) "Insuree-Token": token,
      "App-Version": env.APP_VERSION,
    };

    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
  }


  static Future<http.Response> getRestFullUrl(String fullUrl, {String token = ''}) async {
    return await http.get(
      Uri.parse(fullUrl),
      headers: {
        "Content-Type": "application/json",
        if (true && token.isNotEmpty) "Insuree-Token": token,
        "App-Version": env.APP_VERSION,
      },
    );
  }
}
