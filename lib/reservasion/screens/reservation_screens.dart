import 'package:flutter/material.dart';
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
  final TextEditingController _specialRequestController = TextEditingController();

  List<Map<String, String>> reservations = [];
  int? _editingIndex;

  bool get hasActiveReservation {
    return reservations.any((reservation) => reservation["status"] == "active");
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

  // Save reservations to SharedPreferences
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
            content: Text("You already have an active reservation! Please complete it first."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        if (_editingIndex != null) {
          // Update existing reservation
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
                content: Text("You can only have one active reservation at a time."),
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
          content: Text(_editingIndex == null ? "Reservation saved successfully!" : "Reservation updated successfully!"),
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

  void _editReservation(int index) {
    setState(() {
      _editingIndex = index;
      final reservation = reservations[index];
      _nameController.text = reservation["name"]!;
      _dateController.text = reservation["date"]!;
      _timeController.text = reservation["time"]!;
      _guestsController.text = reservation["guests"]!;
      _contactInfoController.text = reservation["contactInfo"]!;
      _specialRequestController.text = reservation["specialRequest"]!;
    });
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
                      hintText: 'Select a date',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
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
                      hintText: 'Select a time',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () => _selectTime(context),
                      ),
                    ),
                    readOnly: true,
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
                      labelText: 'Number of Guests',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of guests';
                      } else if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Please enter a valid number of guests';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _contactInfoController,
                    decoration: InputDecoration(
                      labelText: 'Contact Info',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide your contact information';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _specialRequestController,
                    decoration: InputDecoration(
                      labelText: 'Special Request (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveReservation,
                    child: Text(_editingIndex == null ? 'Save Reservation' : 'Update Reservation'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: reservations.isEmpty
                  ? Center(
                      child: Text(
                        'No reservations found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              'Reservation for ${reservation["name"]} on ${reservation["date"]}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Time: ${reservation["time"]}'),
                                Text('Guests: ${reservation["guests"]}'),
                                Text('Contact: ${reservation["contactInfo"]}'),
                                if (reservation["specialRequest"] != null &&
                                    reservation["specialRequest"]!.isNotEmpty)
                                  Text(
                                      'Special Request: ${reservation["specialRequest"]}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (reservation["status"] == "active")
                                  IconButton(
                                    icon: Icon(Icons.check, color: Colors.green),
                                    onPressed: () => _completeReservation(index),
                                    tooltip: 'Complete Reservation',
                                  ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editReservation(index),
                                  tooltip: 'Edit Reservation',
                                ),
                                if (reservation["status"] == "completed")
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteReservation(index),
                                    tooltip: 'Delete Reservation',
                                  ),
                              ],
                            ),
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