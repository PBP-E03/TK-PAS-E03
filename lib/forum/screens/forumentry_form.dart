import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';

class ForumEntryFormPage extends StatefulWidget {
  final VoidCallback? onSubmitSuccess;

  const ForumEntryFormPage({
    super.key,
    this.onSubmitSuccess,
  });

  @override
  State<ForumEntryFormPage> createState() => _ForumEntryFormPageState();
}

class _ForumEntryFormPageState extends State<ForumEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRestaurant = "Select a Restaurant";
  String _title = "";
  String _content = "";
  List<String> restaurantList = [];

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
        'https://danniel-steve.pbp.cs.ui.ac.id/resto/flutter/get-restaurants/');

    setState(() {
      restaurantList = List<String>.from(
          response.map((resto) => resto['fields']['name'].toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Steve SteakHouse'),
        backgroundColor: const Color(0xFFBF4141),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Create New Post',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Choose a Restaurant",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  value: _selectedRestaurant,
                  items: [
                    const DropdownMenuItem<String>(
                      value: "Select a Restaurant",
                      child: Text("Select a Restaurant"),
                    ),
                    ...restaurantList.map((String restaurant) {
                      return DropdownMenuItem<String>(
                        value: restaurant,
                        child: Text(restaurant),
                      );
                    }).toList(),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRestaurant = newValue!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value == "Select a Restaurant") {
                      return "Please select a restaurant!";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter post title",
                    labelText: "Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Title cannot be empty!";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Write your post content here",
                    labelText: "Content",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _content = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Content cannot be empty!";
                    }
                    return null;
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final response = await request.postJson(
                          "https://danniel-steve.pbp.cs.ui.ac.id/forum/post/new-flutter/",
                          jsonEncode(<String, dynamic>{
                            'restaurant': _selectedRestaurant,
                            'title': _title,
                            'content': _content,
                          }),
                        );
                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Post successfully created!"),
                            ));
                            widget.onSubmitSuccess?.call();
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text("An error occurred, please try again."),
                            ));
                          }
                        }
                      }
                    },
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
