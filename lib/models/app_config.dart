// To parse this JSON data, do
//
//     final appConfig = appConfigFromJson(jsonString);

import 'dart:convert';

AppConfig appConfigFromJson(String str) => AppConfig.fromJson(json.decode(str));

String appConfigToJson(AppConfig data) => json.encode(data.toJson());

class AppConfig {
  AppConfig({
    required this.appUrl,
    required this.appVersion,
  });

  String appUrl;
  int appVersion;

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
    appUrl: json["app_url"],
    appVersion: json["app_version"],
  );

  Map<String, dynamic> toJson() => {
    "app_url": appUrl,
    "app_version": appVersion,
  };
}
