// To parse this JSON data, do
//
//     final restaurantEntry = restaurantEntryFromJson(jsonString);

import 'dart:convert';

List<RestaurantEntry> restaurantEntryFromJson(String str) =>
    List<RestaurantEntry>.from(
        json.decode(str).map((x) => RestaurantEntry.fromJson(x)));

String restaurantEntryToJson(List<RestaurantEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RestaurantEntry {
  Model model;
  int pk;
  Fields fields;

  RestaurantEntry({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory RestaurantEntry.fromJson(Map<String, dynamic> json) =>
      RestaurantEntry(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  String name;
  int price;
  String location;
  String specialMenu;
  int rating;
  String description;
  String openingTime;
  String closingTime;

  Fields({
    required this.name,
    required this.price,
    required this.location,
    required this.specialMenu,
    required this.rating,
    required this.description,
    required this.openingTime,
    required this.closingTime,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"],
        price: json["price"],
        location: json["location"],
        specialMenu: json["special_menu"],
        rating: json["rating"],
        description: json["description"],
        openingTime: json["opening_time"],
        closingTime: json["closing_time"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "location": location,
        "special_menu": specialMenu,
        "rating": rating,
        "description": description,
        "opening_time": openingTime,
        "closing_time": closingTime,
      };
}

enum Model { RESTO_RESTAURANT }

final modelValues = EnumValues({"resto.restaurant": Model.RESTO_RESTAURANT});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
