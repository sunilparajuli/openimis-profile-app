// To parse this JSON data, do
//
//     final policyInformation = policyInformationFromJson(jsonString);

import 'dart:convert';

PolicyInformation policyInformationFromJson(String str) => PolicyInformation.fromJson(json.decode(str));

String policyInformationToJson(PolicyInformation data) => json.encode(data.toJson());

class PolicyInformation {
  PolicyInformation({
    required this.data,
  });
  
  Data data;
  
  factory PolicyInformation.fromJson(Map<String, dynamic> json) => PolicyInformation(
    data: Data.fromJson(json["data"]),
  );
  
  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
  };
}

class Data {
  Data({
    required this.insureeProfile,
  });
  
  InsureeProfile insureeProfile;
  
  factory Data.fromJson(Map<String, dynamic> json) => Data(
    insureeProfile: InsureeProfile.fromJson(json["insureeProfile"]),
  );
  
  Map<String, dynamic> toJson() => {
    "insureeProfile": insureeProfile.toJson(),
  };
}

class InsureeProfile {
  InsureeProfile({
    required this.chfId,
    required this.lastName,
    required this.otherNames,
    required this.insureePolicies,
  });
  
  String chfId;
  String lastName;
  String otherNames;
  List<InsureePolicy> insureePolicies;
  
  factory InsureeProfile.fromJson(Map<String, dynamic> json) => InsureeProfile(
    chfId: json["chfId"],
    lastName: json["lastName"],
    otherNames: json["otherNames"],
    insureePolicies: List<InsureePolicy>.from(json["insureePolicies"].map((x) => InsureePolicy.fromJson(x))),
  );
  
  Map<String, dynamic> toJson() => {
    "chfId": chfId,
    "lastName": lastName,
    "otherNames": otherNames,
    "insureePolicies": List<dynamic>.from(insureePolicies.map((x) => x.toJson())),
  };
}

class InsureePolicy {
  InsureePolicy({
    required this.policy,
    required this.insuree,
  });
  
  Policy policy;
  Insuree insuree;
  
  factory InsureePolicy.fromJson(Map<String, dynamic> json) => InsureePolicy(
    policy: Policy.fromJson(json["policy"]),
    insuree: Insuree.fromJson(json["insuree"]),
  );
  
  Map<String, dynamic> toJson() => {
    "policy": policy.toJson(),
    "insuree": insuree.toJson(),
  };
}

class Insuree {
  Insuree({
    required this.gender,
    required this.dob,
    required this.healthFacility,
  });
  
  Gender gender;
  DateTime dob;
  HealthFacility healthFacility;
  
  factory Insuree.fromJson(Map<String, dynamic> json) => Insuree(
    gender: Gender.fromJson(json["gender"]),
    dob: DateTime.parse(json["dob"]),
    healthFacility: HealthFacility.fromJson(json["healthFacility"]),
  );
  
  Map<String, dynamic> toJson() => {
    "gender": gender.toJson(),
    "dob": "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}",
    "healthFacility": healthFacility.toJson(),
  };
}

class Gender {
  Gender({
    required this.code,
    required this.gender,
  });
  
  String code;
  String gender;
  
  factory Gender.fromJson(Map<String, dynamic> json) => Gender(
    code: json["code"],
    gender: json["gender"],
  );
  
  Map<String, dynamic> toJson() => {
    "code": code,
    "gender": gender,
  };
}

class HealthFacility {
  HealthFacility({
    required this.code,
    required this.name,
  });
  
  String code;
  String name;
  
  factory HealthFacility.fromJson(Map<String, dynamic> json) => HealthFacility(
    code: json["code"],
    name: json["name"],
  );
  
  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
  };
}

class Policy {
  Policy({
    required this.value,
    required this.startDate,
    required this.enrollDate,
    required this.expiryDate,
    required this.status,
    required this.stage,
  });
  
  double value;
  DateTime? startDate;
  DateTime? enrollDate;
  DateTime expiryDate;
  int status;
  String stage;
  
  factory Policy.fromJson(Map<String, dynamic> json) {
    String parseStage(dynamic stageValue) {
        if (stageValue == null) return '';
        String stageCode = stageValue.toString().trim().toUpperCase();
        if (stageCode == 'N') return 'New';
        if (stageCode == 'R') return 'Renewed';
        return stageValue.toString();
    }

    return Policy(
      value: json["value"] == null ? 0.0 : json["value"].toDouble(),
      startDate: json["startDate"] != null ? DateTime.parse(json["startDate"]) : null,
      enrollDate: json["enrollDate"] != null ? DateTime.parse(json["enrollDate"]) : null,
      expiryDate: DateTime.parse(json["expiryDate"]),
      status: json["status"],
      stage: parseStage(json["stage"]),
    );
  }
  
  Map<String, dynamic> toJson() => {
    "value": value,
    "startDate": startDate != null ? "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}" : null,
    "enrollDate": enrollDate != null ? "${enrollDate!.year.toString().padLeft(4, '0')}-${enrollDate!.month.toString().padLeft(2, '0')}-${enrollDate!.day.toString().padLeft(2, '0')}" : null,
    "expiryDate": "${expiryDate.year.toString().padLeft(4, '0')}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}",
    "status": status,
    "stage": stage,
  };
}
