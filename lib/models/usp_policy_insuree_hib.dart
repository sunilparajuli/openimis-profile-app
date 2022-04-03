// To parse this JSON data, do
//
//     final uspPolicyInsureeHib = uspPolicyInsureeHibFromJson(jsonString);

import 'dart:convert';

UspPolicyInsureeHib uspPolicyInsureeHibFromJson(String str) => UspPolicyInsureeHib.fromJson(json.decode(str));

String uspPolicyInsureeHibToJson(UspPolicyInsureeHib data) => json.encode(data.toJson());

class UspPolicyInsureeHib {
  UspPolicyInsureeHib({
    this.chfid,
    this.dateOfBirth,
    this.gender,
    this.balance,
    this.firstServiceHospital,
    this.expiryDate,
    this.status,
  });

  String chfid;
  String dateOfBirth;
  String gender;
  double balance;
  String firstServiceHospital;
  String expiryDate;
  String status;

  factory UspPolicyInsureeHib.fromJson(Map<String, dynamic> json) => UspPolicyInsureeHib(
    chfid: json["chfid"],
    dateOfBirth: json["date_of_birth"],
    gender: json["gender"],
    balance: json["balance"].toDouble(),
    firstServiceHospital: json["first_service_hospital"],
    expiryDate: json["expiry_date"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "chfid": chfid,
    "date_of_birth": dateOfBirth,
    "gender": gender,
    "balance": balance,
    "first_service_hospital": firstServiceHospital,
    "expiry_date": expiryDate,
    "status": status,
  };
}
