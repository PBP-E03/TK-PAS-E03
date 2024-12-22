import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _specialRequestController =
      TextEditingController();

  List<Map<String, String>> reservations = [];
  int? _editingIndex;

  bool get hasActiveReservation {
    return reservations.any((reservation) => reservation["status"] == "active");
  }

  Future<List<Map<String, String>>> fetchReservations() async {
    try {
      // Simulating a fetch from an API (or database)
      final response = await Future.delayed(Duration(seconds: 1), () {
        return {'status': 'success', 'reservations': []}; // Mock data
      });

      if (response['status'] == 'success') {
        return List<Map<String, String>>.from(response['reservations'] as List);
      } else {
        throw Exception("Failed to load reservations.");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> _loadReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedReservations = prefs.getString('reservations');
    if (savedReservations != null) {
      final List<dynamic> reservationList = json.decode(savedReservations);
      setState(() {
        reservations = List<Map<String, String>>.from(
            reservationList.map((item) => Map<String, String>.from(item)));
      });
    }
  }

  Future<void> _saveReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final String reservationsJson = json.encode(reservations);
    prefs.setString('reservations', reservationsJson);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        String formattedDate =
            '${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}';
        _dateController.text = formattedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        String formattedTime =
            '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
        _timeController.text = formattedTime;
      });
    }
  }

  void _saveReservation() {
    if (_formKey.currentState!.validate()) {
      if (hasActiveReservation && _editingIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "You already have an active reservation! Please complete it first."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        if (_editingIndex != null) {
          reservations[_editingIndex!] = {
            "name": _nameController.text,
            "date": _dateController.text,
            "time": _timeController.text,
            "guests": _guestsController.text,
            "contactInfo": _contactInfoController.text,
            "specialRequest": _specialRequestController.text,
            "status": "active",
            "user": "user_id_here",
            "restaurant": "restaurant_id_here",
          };
        } else {
          if (!hasActiveReservation) {
            reservations.add({
              "name": _nameController.text,
              "date": _dateController.text,
              "time": _timeController.text,
              "guests": _guestsController.text,
              "contactInfo": _contactInfoController.text,
              "specialRequest": _specialRequestController.text,
              "status": "active",
              "user": "user_id_here",
              "restaurant": "restaurant_id_here",
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text("You can only have one active reservation at a time."),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });

      _saveReservations();
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editingIndex == null
              ? "Reservation saved successfully!"
              : "Reservation updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _dateController.clear();
    _timeController.clear();
    _guestsController.clear();
    _contactInfoController.clear();
    _specialRequestController.clear();
    setState(() {
      _editingIndex = null;
    });
  }

  void _completeReservation(int index) {
    setState(() {
      reservations[index]["status"] = "completed";
      reservations.removeAt(index);
    });
    _saveReservations();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Reservation completed and deleted!"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteReservation(int index) {
    setState(() {
      reservations.removeAt(index);
    });
    _saveReservations();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Reservation deleted!"),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _editReservation(
      int reservationId,
      String editedName,
      String editedDate,
      String editedTime,
      int editedGuests,
      String editedContactInfo,
      String editedSpecialRequest) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
        "https://danniel-steve.pbp.cs.ui.ac.id/reservation/edit-flutter/",
        jsonEncode({
          'reservation_id': reservationId.toString(),
          'name': editedName,
          'date': editedDate,
          'time': editedTime,
          'guests': editedGuests.toString(),
          'contact_info': editedContactInfo,
          'special_request': editedSpecialRequest,
        }),
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reservation updated!")));
        final updatedReservations = await fetchReservations();

        setState(() {
          reservations = updatedReservations;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update reservation.")));
      }
    } catch (e) {
      // Handle error if the request fails
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showEditReservationDialog(int index, Map<String, String> reservation) {
    showDialog(
      context: context,
      builder: (context) {
        return EditReservationDialog(
          initialName: reservation["name"]!,
          initialDate: reservation["date"]!,
          initialTime: reservation["time"]!,
          initialGuests: reservation["guests"]!,
          initialContactInfo: reservation["contactInfo"]!,
          initialSpecialRequest: reservation["specialRequest"]!,
          onEdit:
              (name, date, time, guests, contactInfo, specialRequest) async {
            await _editReservation(int.parse(reservation["id"]!), name, date,
                time, int.parse(guests), contactInfo, specialRequest);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _guestsController.dispose();
    _contactInfoController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () => _selectTime(context),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a time';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _guestsController,
                    decoration: InputDecoration(
                      labelText: 'Number of guests',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of guests';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _contactInfoController,
                    decoration: InputDecoration(
                      labelText: 'Contact info',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact info';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _specialRequestController,
                    decoration: InputDecoration(
                      labelText: 'Special requests',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveReservation,
                    child: Text('Save Reservation'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: reservations.length,
                itemBuilder: (context, index) {
                  final reservation = reservations[index];
                  return Card(
                    child: ListTile(
                      title: Text(reservation["name"]!),
                      subtitle: Text(
                          "Date: ${reservation["date"]}, Time: ${reservation["time"]}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (reservation["status"] == "active")
                            IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () => _completeReservation(index),
                            ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteReservation(index),
                          ),
                        ],
                      ),
                      onTap: () =>
                          _showEditReservationDialog(index, reservation),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditReservationDialog extends StatelessWidget {
  final String initialName;
  final String initialDate;
  final String initialTime;
  final String initialGuests;
  final String initialContactInfo;
  final String initialSpecialRequest;
  final Function(String, String, String, String, String, String) onEdit;

  EditReservationDialog({
    required this.initialName,
    required this.initialDate,
    required this.initialTime,
    required this.initialGuests,
    required this.initialContactInfo,
    required this.initialSpecialRequest,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController =
        TextEditingController(text: initialName);
    final TextEditingController _dateController =
        TextEditingController(text: initialDate);
    final TextEditingController _timeController =
        TextEditingController(text: initialTime);
    final TextEditingController _guestsController =
        TextEditingController(text: initialGuests);
    final TextEditingController _contactInfoController =
        TextEditingController(text: initialContactInfo);
    final TextEditingController _specialRequestController =
        TextEditingController(text: initialSpecialRequest);

    return AlertDialog(
      title: Text('Edit Reservation'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextFormField(
            controller: _dateController,
            decoration: InputDecoration(labelText: 'Date'),
          ),
          TextFormField(
            controller: _timeController,
            decoration: InputDecoration(labelText: 'Time'),
          ),
          TextFormField(
            controller: _guestsController,
            decoration: InputDecoration(labelText: 'Guests'),
          ),
          TextFormField(
            controller: _contactInfoController,
            decoration: InputDecoration(labelText: 'Contact Info'),
          ),
          TextFormField(
            controller: _specialRequestController,
            decoration: InputDecoration(labelText: 'Special Request'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            onEdit(
              _nameController.text,
              _dateController.text,
              _timeController.text,
              _guestsController.text,
              _contactInfoController.text,
              _specialRequestController.text,
            );
            Navigator.of(context).pop();
          },
          child: Text('Save Changes'),
        ),
      ],
    );
  }
}
