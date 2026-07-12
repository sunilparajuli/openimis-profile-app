// To parse this JSON data, do
//
//     final insureeData = insureeDataFromJson(jsonString);

import 'dart:convert';

InsureeData insureeDataFromJson(String str) => InsureeData.fromJson(json.decode(str));

String insureeDataToJson(InsureeData data) => json.encode(data.toJson());

class InsureeData {
  InsureeData({
    required this.data,
  });

  Data data;

  factory InsureeData.fromJson(Map<String, dynamic> json) => InsureeData(
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
  };
}

class Data {
  Data({
    required this.profile,
  });

  Profile profile;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    profile: Profile.fromJson(json["profile"]),
  );

  Map<String, dynamic> toJson() => {
    "profile": profile.toJson(),
  };
}

class Profile {
  Profile({
    required this.phone,
    this.email,
    this.photo,
    required this.remainingDays,
    required this.insuree,
  });

  String phone;
  String? email;
  String? photo;
  String remainingDays;
  Insuree insuree;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    phone: json["phone"] ?? "",
    email: json["email"],
    photo: json["photo"],
    remainingDays: json["remainingDays"]?.toString() ?? "",
    insuree: Insuree.fromJson(json["insuree"]),
  );

  Map<String, dynamic> toJson() => {
    "phone": phone,
    "email": email,
    "photo": photo,
    "remainingDays": remainingDays,
    "insuree": insuree.toJson(),
  };
}

class Insuree {
  Insuree({
    required this.insureePolicies,
    required this.otherNames,
    required this.lastName,
    required this.dob,
    this.currentAddress,
    this.validityTo,
    required this.healthFacility,
  });

  List<InsureePolicy> insureePolicies;
  String otherNames;
  String lastName;
  DateTime dob;
  String? currentAddress;
  dynamic validityTo;
  HealthFacility healthFacility;

  factory Insuree.fromJson(Map<String, dynamic> json) => Insuree(
    insureePolicies: json["insureePolicies"] == null 
        ? [] 
        : List<InsureePolicy>.from(json["insureePolicies"].map((x) => InsureePolicy.fromJson(x))),
    otherNames: json["otherNames"] ?? "",
    lastName: json["lastName"] ?? "",
    dob: json["dob"] == null ? DateTime.now() : DateTime.parse(json["dob"]),
    currentAddress: json["currentAddress"],
    validityTo: json["validityTo"],
    healthFacility: HealthFacility.fromJson(json["healthFacility"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "insureePolicies": List<dynamic>.from(insureePolicies.map((x) => x.toJson())),
    "otherNames": otherNames,
    "lastName": lastName,
    "dob": "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}",
    "currentAddress": currentAddress,
    "validityTo": validityTo,
    "healthFacility": healthFacility.toJson(),
  };
}

class HealthFacility {
  HealthFacility({
    this.name,
  });

  String? name;

  factory HealthFacility.fromJson(Map<String, dynamic> json) => HealthFacility(
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
  };
}

class InsureePolicy {
  InsureePolicy({
    required this.policy,
  });

  Policy policy;

  factory InsureePolicy.fromJson(Map<String, dynamic> json) => InsureePolicy(
    policy: Policy.fromJson(json["policy"]),
  );

  Map<String, dynamic> toJson() => {
    "policy": policy.toJson(),
  };
}

class Policy {
  Policy({
    required this.value,
    required this.expiryDate,
  });

  double value;
  DateTime expiryDate;

  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
    value: (json["value"] ?? 0).toDouble(),
    expiryDate: json["expiryDate"] == null ? DateTime.now() : DateTime.parse(json["expiryDate"]),
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "expiryDate": "${expiryDate.year.toString().padLeft(4, '0')}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}",
  };
}
