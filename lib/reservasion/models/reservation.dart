import 'dart:convert';

// Function to parse reservation list from JSON string
List<Reservation> reservationFromJson(String str) =>
    List<Reservation>.from(json.decode(str).map((x) => Reservation.fromJson(x)));

// Function to encode reservation list to JSON string
String reservationToJson(List<Reservation> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// Main Reservation class
class Reservation {
  String model;
  int pk;
  ReservationFields fields;

  Reservation({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
        model: json["model"] as String,
        pk: json["pk"] as int,
        fields: ReservationFields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class ReservationFields {
  String name;
  String date;
  String time;
  int numberOfGuests;
  String contactInfo;
  String specialRequest;
  ReservationStatus status;

  ReservationFields({
    required this.name,
    required this.date,
    required this.time,
    required this.numberOfGuests,
    required this.contactInfo,
    required this.specialRequest,
    required this.status,
  });

  factory ReservationFields.fromJson(Map<String, dynamic> json) => ReservationFields(
        name: json["name"],
        date: json["date"],
        time: json["time"],
        numberOfGuests: json["number_of_guests"],
        contactInfo: json["contact_info"],
        specialRequest: json["special_request"],
        status: ReservationStatus.values.firstWhere(
          (e) => e.name == json["status"],
          orElse: () => ReservationStatus.active, // Default to 'active'
        ),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "date": date,
        "time": time,
        "number_of_guests": numberOfGuests,
        "contact_info": contactInfo,
        "special_request": specialRequest,
        "status": status.name,
      };
}

enum ReservationStatus { active, completed }