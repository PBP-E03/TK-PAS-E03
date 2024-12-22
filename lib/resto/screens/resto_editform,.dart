import 'package:flutter/material.dart';
import 'package:steve_mobile/resto/models/restaurant_entry.dart';
import 'package:steve_mobile/widgets/leftdrawer.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';

class RestoEditEntryFormPage extends StatefulWidget {
  const RestoEditEntryFormPage(
      {super.key, required this.restaurant, this.onEditComplete});
  final RestaurantEntry restaurant;
  final VoidCallback? onEditComplete;

  @override
  _RestoEditEntryFormPageState createState() => _RestoEditEntryFormPageState();
}

class _RestoEditEntryFormPageState extends State<RestoEditEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  // Attribute Definition
  String _name = '';
  String _address = '';
  int _price = 0;
  String _specialMenu = '';
  String _description = '';
  TimeOfDay _openTime = TimeOfDay.now();
  TimeOfDay _closeTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _name = widget.restaurant.fields.name;
    _address = widget.restaurant.fields.location;
    _price = widget.restaurant.fields.price;
    _specialMenu = widget.restaurant.fields.specialMenu;
    _description = widget.restaurant.fields.description;
  }

  // Method to show time picker
  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTime : _closeTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  // Custom input decoration
  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = Provider.of<CookieRequest>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Restaurant"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Restaurant Name
              TextFormField(
                initialValue: _name,
                decoration: _buildInputDecoration(
                    'Restaurant Name', 'Enter restaurant name'),
                onChanged: (value) => setState(() => _name = value),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter restaurant name'
                    : null,
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                initialValue: _address,
                decoration: _buildInputDecoration(
                    'Restaurant Address', 'Enter restaurant address'),
                onChanged: (value) => setState(() => _address = value),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter restaurant address'
                    : null,
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                initialValue: _price.toString(),
                decoration: _buildInputDecoration(
                    'Price', 'Enter average price per person'),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    setState(() => _price = int.tryParse(value) ?? 0),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter price';
                  if (int.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Special Menu
              TextFormField(
                initialValue: _specialMenu,
                decoration: _buildInputDecoration(
                    'Special Menu', 'Enter special menu items'),
                onChanged: (value) => setState(() => _specialMenu = value),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter special menu' : null,
              ),
              const SizedBox(height: 16),

              // Operating Hours
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, true),
                      child: InputDecorator(
                        decoration: _buildInputDecoration('Opening Time', ''),
                        child: Text(
                          _openTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, false),
                      child: InputDecorator(
                        decoration: _buildInputDecoration('Closing Time', ''),
                        child: Text(
                          _closeTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                initialValue: _description,
                decoration: _buildInputDecoration(
                        'Description', 'Enter restaurant description')
                    .copyWith(
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                onChanged: (value) => setState(() => _description = value),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              const SizedBox(height: 24),

              // Submit Button
              Row(
                children: [
                  // Primary Action Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Handle form submission here
                          final response = await request.postJson(
                            "http://danniel-steve.pbp.cs.ui.ac.id/flutter/edit-resto/",
                            jsonEncode(<String, String>{
                              'id': widget.restaurant.pk.toString(),
                              'name': _name,
                              'address': _address,
                              'price': _price.toString(),
                              'special_menu': _specialMenu,
                              'description': _description,
                              'open_time':
                                  '${_openTime.hour.toString().padLeft(2, '0')}:${_openTime.minute.toString().padLeft(2, '0')}:00.000000',
                              'close_time':
                                  '${_closeTime.hour.toString().padLeft(2, '0')}:${_closeTime.minute.toString().padLeft(2, '0')}:00.000000',
                            }),
                          );

                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Successfully edited restaurant'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              widget.onEditComplete!();
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to edit restaurant'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Edit Restaurant',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Secondary Action Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[600]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.cancel, color: Colors.grey),
                      label: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
