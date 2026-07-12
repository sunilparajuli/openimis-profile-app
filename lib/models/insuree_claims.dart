// To parse this JSON data, do
//
//     final claims = claimsFromJson(jsonString);

import 'dart:convert';

Claims claimsFromJson(String str) => Claims.fromJson(json.decode(str));

String claimsToJson(Claims data) => json.encode(data.toJson());

class Claims {
	Claims({
		required this.data,
	});

	Data data;

	factory Claims.fromJson(Map<String, dynamic> json) => Claims(
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
		required this.insureeClaim,
	});

	List<InsureeClaim> insureeClaim;

	factory InsureeProfile.fromJson(Map<String, dynamic> json) => InsureeProfile(
		insureeClaim: json["insureeClaim"] == null 
			? [] 
			: List<InsureeClaim>.from(json["insureeClaim"].map((x) => InsureeClaim.fromJson(x))),
	);

	Map<String, dynamic> toJson() => {
		"insureeClaim": List<dynamic>.from(insureeClaim.map((x) => x.toJson())),
	};
}

class InsureeClaim {
	InsureeClaim({
		required this.id,
		required this.dateClaimed,
		required this.claimed,
		required this.status,
		required this.healthFacility,
	});

	String id;
	DateTime dateClaimed;
	double claimed;
	int status;
	HealthFacility healthFacility;

	factory InsureeClaim.fromJson(Map<String, dynamic> json) => InsureeClaim(
		id: json["id"]?.toString() ?? "",
		dateClaimed: json["dateClaimed"] == null ? DateTime.now() : DateTime.parse(json["dateClaimed"]),
		claimed: (json["claimed"] ?? 0).toDouble(),
		status: json["status"] ?? 0,
		healthFacility: HealthFacility.fromJson(json["healthFacility"] ?? {}),
	);

	Map<String, dynamic> toJson() => {
		"id": id,
		"dateClaimed": "${dateClaimed.year.toString().padLeft(4, '0')}-${dateClaimed.month.toString().padLeft(2, '0')}-${dateClaimed.day.toString().padLeft(2, '0')}",
		"claimed": claimed,
		"status": status,
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
