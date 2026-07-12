// To parse this JSON data, do
//
//     final uspPolicyInsureeHib = uspPolicyInsureeHibFromJson(jsonString);

import 'dart:convert';

UspPolicyInsureeHib uspPolicyInsureeHibFromJson(String str) => UspPolicyInsureeHib.fromJson(json.decode(str));

String uspPolicyInsureeHibToJson(UspPolicyInsureeHib data) => json.encode(data.toJson());

class UspPolicyInsureeHib {
  UspPolicyInsureeHib({
    required this.name,
    required this.chfid,
    required this.dateOfBirth,
    required this.gender,
    required this.balance,
    required this.firstServiceHospital,
    required this.expiryDate,
    required this.status,
  });

  String name;
  String chfid;
  String dateOfBirth;
  String gender;
  double balance;
  String firstServiceHospital;
  String expiryDate;
  String status;

  factory UspPolicyInsureeHib.fromJson(Map<String, dynamic> json) => UspPolicyInsureeHib(
    name: json["name"],
    chfid: json["chfid"],
    dateOfBirth: json["date_of_birth"],
    gender: json["gender"],
    balance: json["balance"].toDouble(),
    firstServiceHospital: json["first_service_hospital"],
    expiryDate: json["expiry_date"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "chfid": chfid,
    "date_of_birth": dateOfBirth,
    "gender": gender,
    "balance": balance,
    "first_service_hospital": firstServiceHospital,
    "expiry_date": expiryDate,
    "status": status,
  };
}