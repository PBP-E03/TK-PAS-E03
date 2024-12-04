import 'dart:convert';

// Temporary review entry model (simulating review data)
List<ReviewEntry> reviewEntryFromJson(String str) => List<ReviewEntry>.from(
    json.decode(str).map((x) => ReviewEntry.fromJson(x)));

String reviewEntryToJson(List<ReviewEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewEntry {
  String model;
  String pk;
  ReviewFields fields;

  ReviewEntry({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory ReviewEntry.fromJson(Map<String, dynamic> json) => ReviewEntry(
        model: json["model"],
        pk: json["pk"],
        fields: ReviewFields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class ReviewFields {
  int user;
  String reviewerName;
  String text;
  int rating;
  DateTime date;

  ReviewFields({
    required this.user,
    required this.reviewerName,
    required this.text,
    required this.rating,
    required this.date,
  });

  factory ReviewFields.fromJson(Map<String, dynamic> json) => ReviewFields(
        user: json["user"],
        reviewerName: json["reviewerName"],
        text: json["text"],
        rating: json["rating"].toDouble(),
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "reviewerName": reviewerName,
        "text": text,
        "rating": rating,
        "date": date.toIso8601String(),
      };
}

// Example of simulated review data (can be removed later)
List<ReviewEntry> dummyReviews = [
  ReviewEntry(
    model: "review",
    pk: "1",
    fields: ReviewFields(
      user: 1,
      reviewerName: "test1",
      text: "111",
      rating: 5,
      date: DateTime.now().subtract(Duration(days: 2)),
    ),
  ),
  ReviewEntry(
    model: "review",
    pk: "2",
    fields: ReviewFields(
      user: 2,
      reviewerName: "test2",
      text: "222",
      rating: 3,
      date: DateTime.now().subtract(Duration(days: 1)),
    ),
  ),
];
