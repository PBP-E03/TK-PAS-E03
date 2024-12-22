import 'dart:convert';

WishlistItem wishlistItemFromJson(String str) =>
    WishlistItem.fromJson(json.decode(str));

String wishlistItemToJson(WishlistItem data) => json.encode(data.toJson());

class WishlistItem {
  String model;
  int pk;
  WishlistItemFields fields;

  WishlistItem({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        model: json["model"],
        pk: json["pk"],
        fields: WishlistItemFields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class WishlistItemFields {
  int restaurant;
  int user;
  String title;
  int wishlistCategory;
  DateTime createdAt;

  WishlistItemFields({
    required this.restaurant,
    required this.user,
    required this.title,
    required this.wishlistCategory,
    required this.createdAt,
  });

  factory WishlistItemFields.fromJson(Map<String, dynamic> json) =>
      WishlistItemFields(
        restaurant: json["restaurant"],
        user: json["user"],
        title: json["title"],
        wishlistCategory: json["wishlistCategory"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "restaurant": restaurant,
        "user": user,
        "title": title,
        "wishlistCategory": wishlistCategory,
        "created_at": createdAt.toIso8601String(),
      };
}
