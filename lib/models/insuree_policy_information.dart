// To parse this JSON data, do
//
//     final insureePolicyInformation = insureePolicyInformationFromJson(jsonString);

import 'dart:convert';

InsureePolicyInformation insureePolicyInformationFromJson(String str) => InsureePolicyInformation.fromJson(json.decode(str));

String insureePolicyInformationToJson(InsureePolicyInformation data) => json.encode(data.toJson());

class InsureePolicyInformation {
    InsureePolicyInformation({
        required this.data,
    });

    Data data;

    factory InsureePolicyInformation.fromJson(Map<String, dynamic> json) => InsureePolicyInformation(
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson()
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

    List<InsureePolicy> insureePoliciesSorted() {
        this.insureePolicies.sort((a, b) => b.policy.expiryDate.compareTo(a.policy.expiryDate));
        return this.insureePolicies;
    }
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
        required this.product,
        required this.stage,
    });

    double value;
    DateTime? startDate;
    DateTime? enrollDate;
    DateTime expiryDate;
    int status;
    Product product;
    String stage;

    factory Policy.fromJson(Map<String, dynamic> json) {
        // Helper to convert 'N'/'n' to 'New' and 'R'/'r' to 'Renewed'
        String parseStage(dynamic stageValue) {
            if (stageValue == null) return '';

            String stageCode = stageValue.toString().trim().toUpperCase();
            if (stageCode == 'N') return 'New';
            if (stageCode == 'R') return 'Renewed';

            return stageValue.toString(); // Fallback if it's something else
        }

        return Policy(
            value: json["value"] == null ? 0.0 : json["value"].toDouble(),
            startDate: json["startDate"] != null ? DateTime.parse(json["startDate"]) : null,
            enrollDate: json["enrollDate"] != null ? DateTime.parse(json["enrollDate"]) : null,
            expiryDate: DateTime.parse(json["expiryDate"]),
            status: json["status"],
            product: Product.fromJson(json["product"]),
            stage: parseStage(json["stage"]), // <-- Applied the logic here
        );
    }

    Map<String, dynamic> toJson() => {
        "value": value,
        "startDate": startDate != null ? "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}" : null,
        "enrollDate": enrollDate != null ? "${enrollDate!.year.toString().padLeft(4, '0')}-${enrollDate!.month.toString().padLeft(2, '0')}-${enrollDate!.day.toString().padLeft(2, '0')}" : null,
        "expiryDate": "${expiryDate.year.toString().padLeft(4, '0')}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}",
        "status": status,
        "stage": stage,
        "product": product.toJson(),
    };
}
class Product {
    Product({
        required this.name,
    });

    String name;

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
    };
}