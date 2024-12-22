// To parse this JSON data, do
//
//     final ratingEntry = ratingEntryFromJson(jsonString);

import 'dart:convert';

List<RatingEntry> ratingEntryFromJson(String str) => List<RatingEntry>.from(json.decode(str).map((x) => RatingEntry.fromJson(x)));

String ratingEntryToJson(List<RatingEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RatingEntry {
    String model;
    int pk;
    Fields fields;

    RatingEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory RatingEntry.fromJson(Map<String, dynamic> json) => RatingEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int restaurant;
    int user;
    int rating;
    String comment;
    DateTime createdAt;

    Fields({
        required this.restaurant,
        required this.user,
        required this.rating,
        required this.comment,
        required this.createdAt,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        restaurant: json["restaurant"],
        user: json["user"],
        rating: json["rating"],
        comment: json["comment"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "restaurant": restaurant,
        "user": user,
        "rating": rating,
        "comment": comment,
        "created_at": createdAt.toIso8601String(),
    };
}
