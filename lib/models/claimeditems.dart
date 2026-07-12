// To parse this JSON data, do
//
//     final claimedItems = claimedItemsFromJson(jsonString);

import 'dart:convert';

ClaimedItems claimedItemsFromJson(String str) => ClaimedItems.fromJson(json.decode(str));

String claimedItemsToJson(ClaimedItems data) => json.encode(data.toJson());

class ClaimedItems {
  ClaimedItems({
    required this.data,
  });

  Data data;

  factory ClaimedItems.fromJson(Map<String, dynamic> json) => ClaimedItems(
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
  };
}

class Data {
  Data({
    required this.insureeClaim,
  });

  List<InsureeClaim> insureeClaim;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    insureeClaim: List<InsureeClaim>.from(json["insureeClaim"].map((x) => InsureeClaim.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "insureeClaim": List<dynamic>.from(insureeClaim.map((x) => x.toJson())),
  };
}

class InsureeClaim {
  InsureeClaim({
    required this.items,
  });

  List<ItemElement> items;

  factory InsureeClaim.fromJson(Map<String, dynamic> json) => InsureeClaim(
    items: List<ItemElement>.from(json["items"].map((x) => ItemElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class ItemElement {
  ItemElement({
    required this.id,
    required this.qtyProvided,
    required this.qtyApproved,
    required this.item,
  });

  String id;
  double qtyProvided;
  double qtyApproved;
  ItemItem item;

  factory ItemElement.fromJson(Map<String, dynamic> json) => ItemElement(
    id: json["id"]?.toString() ?? "",
    qtyProvided: (json["qtyProvided"] ?? 0).toDouble(),
    qtyApproved: (json["qtyApproved"] ?? 0).toDouble(),
    item: ItemItem.fromJson(json["item"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "qtyProvided": qtyProvided,
    "qtyApproved": qtyApproved,
    "item": item.toJson(),
  };
}

class ItemItem {
  ItemItem({
    required this.id,
    required this.name,
    required this.price,
  });

  String id;
  String name;
  double price;

  factory ItemItem.fromJson(Map<String, dynamic> json) => ItemItem(
    id: json["id"]?.toString() ?? "",
    name: json["name"] ?? "N/A",
    price: (json["price"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
  };
}
