class AppContactsModel {
  final Data data;

  AppContactsModel({required this.data});

  factory AppContactsModel.fromJson(Map<String, dynamic> json) {
    return AppContactsModel(
      data: Data.fromJson(json['data'] ?? {}),
    );
  }
}

class Data {
  final AppContacts appContacts;

  Data({required this.appContacts});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      appContacts: AppContacts.fromJson(json['appContacts'] ?? {}),
    );
  }
}

class AppContacts {
  final List<ContactDetail> provinceContacts;
  final List<ContactDetail> districtContacts;

  AppContacts({required this.provinceContacts, required this.districtContacts});

  factory AppContacts.fromJson(Map<String, dynamic> json) {
    var pList = json['provinceContacts'] as List? ?? [];
    var dList = json['districtContacts'] as List? ?? [];

    return AppContacts(
      provinceContacts: pList.map((i) => ContactDetail.fromJson(i)).toList(),
      districtContacts: dList.map((i) => ContactDetail.fromJson(i)).toList(),
    );
  }
}

class ContactDetail {
  final String branch;
  final String address;
  final String email;
  final String phone;

  ContactDetail({
    required this.branch,
    required this.address,
    required this.email,
    required this.phone,
  });

  factory ContactDetail.fromJson(Map<String, dynamic> json) {
    return ContactDetail(
      branch: json['branch'] ?? 'Unknown Branch',
      address: json['address'] ?? 'No Address',
      email: json['email'] ?? 'No Email',
      phone: json['phone'] ?? 'No Phone',
    );
  }
}