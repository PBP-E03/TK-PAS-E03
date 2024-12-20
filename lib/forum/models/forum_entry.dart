// To parse this JSON data, do
//
//     final forumEntry = forumEntryFromJson(jsonString);

import 'dart:convert';

List<ForumEntry> forumEntryFromJson(String str) => List<ForumEntry>.from(json.decode(str).map((x) => ForumEntry.fromJson(x)));

String forumEntryToJson(List<ForumEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForumEntry {
    String model;
    int pk;
    Fields fields;

    ForumEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory ForumEntry.fromJson(Map<String, dynamic> json) => ForumEntry(
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
    String title;
    String content;
    DateTime datePosted;
    int author;
    int upvotes;
    int downvotes;
    int resto;

    Fields({
        required this.title,
        required this.content,
        required this.datePosted,
        required this.author,
        required this.upvotes,
        required this.downvotes,
        required this.resto,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"],
        content: json["content"],
        datePosted: DateTime.parse(json["date_posted"]),
        author: json["author"],
        upvotes: json["upvotes"],
        downvotes: json["downvotes"],
        resto: json["resto"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "content": content,
        "date_posted": datePosted.toIso8601String(),
        "author": author,
        "upvotes": upvotes,
        "downvotes": downvotes,
        "resto": resto,
    };
}
