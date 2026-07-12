class HealthFacilityCoordinates {
    Data? data;
    
    HealthFacilityCoordinates({this.data});
    
    HealthFacilityCoordinates.fromJson(Map<String, dynamic> json) {
        data = json['data'] != null ? Data.fromJson(json['data']) : null;
    }
    
    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        if (this.data != null) {
            data['data'] = this.data!.toJson();
        }
        return data;
    }
}

class Data {
    List<HealthFacilityCoordinate> healthFacilityCoordinate = [];
    
    Data({List<HealthFacilityCoordinate>? healthFacilityCoordinate})
        : healthFacilityCoordinate = healthFacilityCoordinate ?? [];
    
    Data.fromJson(Map<String, dynamic> json) {
        if (json['healthFacilityCoordinate'] != null) {
            healthFacilityCoordinate = <HealthFacilityCoordinate>[];
            json['healthFacilityCoordinate'].forEach((item) {
                healthFacilityCoordinate.add(HealthFacilityCoordinate.fromJson(item));
            });
        }
    }
    
    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['healthFacilityCoordinate'] =
            this.healthFacilityCoordinate.map((item) => item.toJson()).toList();
        return data;
    }
}

class HealthFacilityCoordinate {
    String id;
    double distance = 0.0;
    HealthFacility? healthFacility;
    
    HealthFacilityCoordinate({required this.id, this.distance = 0.0, this.healthFacility});
    
    HealthFacilityCoordinate.fromJson(Map<String, dynamic> json)
        : id = json['id'] ?? '',
          distance = (json['distance'] ?? 0).toDouble(),
          healthFacility = json['healthFacility'] != null
            ? HealthFacility.fromJson(json['healthFacility'])
            : null;
    
    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = this.id;
        data['distance'] = this.distance;
        if (this.healthFacility != null) {
            data['healthFacility'] = this.healthFacility!.toJson();
        }
        return data;
    }
}

class HealthFacility {
    String id;
    String name = "";
    
    HealthFacility({required this.id, this.name = ""});
    
    HealthFacility.fromJson(Map<String, dynamic> json)
        : id = json['id'] ?? '',
          name = json['name'] ?? '';
    
    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = this.id;
        data['name'] = this.name;
        return data;
    }
}