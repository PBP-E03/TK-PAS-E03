import 'dart:convert';

WishlistCategory wishlistCategoryFromJson(String str) =>
    WishlistCategory.fromJson(json.decode(str));

String wishlistCategoryToJson(WishlistCategory data) =>
    json.encode(data.toJson());

class WishlistCategory {
  String model;
  int pk;
  WishlistCategoryFields fields;

  WishlistCategory({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory WishlistCategory.fromJson(Map<String, dynamic> json) =>
      WishlistCategory(
        model: json["model"],
        pk: json["pk"],
        fields: WishlistCategoryFields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class WishlistCategoryFields {
  int user;
  String name;
  DateTime createdAt;

  WishlistCategoryFields({
    required this.user,
    required this.name,
    required this.createdAt,
  });

  factory WishlistCategoryFields.fromJson(Map<String, dynamic> json) =>
      WishlistCategoryFields(
        user: json["user"],
        name: json["name"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "name": name,
        "created_at": createdAt.toIso8601String(),
      };
}
