class ServiceProvidersModel {
  Data? data;

  ServiceProvidersModel({this.data});

  ServiceProvidersModel.fromJson(Map<String, dynamic> json) {
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
  ServiceProvidersConnection? serviceProviders;

  Data({this.serviceProviders});

  Data.fromJson(Map<String, dynamic> json) {
    serviceProviders = json['serviceProviders'] != null
        ? ServiceProvidersConnection.fromJson(json['serviceProviders'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.serviceProviders != null) {
      data['serviceProviders'] = this.serviceProviders!.toJson();
    }
    return data;
  }
}

class ServiceProvidersConnection {
  List<ServiceProviderEdge> edges = [];

  ServiceProvidersConnection({List<ServiceProviderEdge>? edges})
      : edges = edges ?? [];

  ServiceProvidersConnection.fromJson(Map<String, dynamic> json) {
    if (json['edges'] != null) {
      edges = <ServiceProviderEdge>[];
      json['edges'].forEach((item) {
        edges.add(ServiceProviderEdge.fromJson(item));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['edges'] = this.edges.map((item) => item.toJson()).toList();
    return data;
  }
}

class ServiceProviderEdge {
  ServiceProviderNode? node;

  ServiceProviderEdge({this.node});

  ServiceProviderEdge.fromJson(Map<String, dynamic> json) {
    node = json['node'] != null ? ServiceProviderNode.fromJson(json['node']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.node != null) {
      data['node'] = this.node!.toJson();
    }
    return data;
  }
}

class ServiceProviderNode {
  String id;
  String name;
  String code;
  double? latitude;
  double? longitude;

  ServiceProviderNode({
    this.id = "",
    this.name = "",
    this.code = "",
    this.latitude,
    this.longitude,
  });

  ServiceProviderNode.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString() ?? '',
        name = json['name']?.toString() ?? '',
        code = json['code']?.toString() ?? '',
        latitude = json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
        longitude = json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}