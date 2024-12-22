import 'package:flutter/material.dart';
import '../../review/review_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

// Models
import 'package:steve_mobile/resto/models/restaurant_entry.dart';
import 'package:steve_mobile/review/screens/review_page.dart';

class SteakhousePage extends StatefulWidget {
  final RestaurantEntry restaurant;
  const SteakhousePage({super.key, required this.restaurant});

  @override
  State<SteakhousePage> createState() => _SteakhousePageState();
}

class _SteakhousePageState extends State<SteakhousePage> {
  late String steakhouseName;
  late int restaurantID;

  @override
  void initState() {
    super.initState();
    steakhouseName = widget.restaurant.fields.name;
    restaurantID = widget.restaurant.pk;
  }

  List<ReviewEntry> reviews = List.from(dummyReviews); // Simulated review data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.fields.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant.fields.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Location: ${restaurant.fields.location}"),
            Text("Price: \$${restaurant.fields.price}"),
            Text("Rating: ${restaurant.fields.rating}"),
            const SizedBox(height: 16),
            Text("Description:"),
            Text(restaurant.fields.description),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to reviews page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewsPage(restaurantId: restaurant.pk),
                      ),
                    );
                  },
                  child: const Text("View Reviews"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to reservation form
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationFormPage(restaurantId: restaurant.pk),
                      ),
                    );
                  },
                  child: const Text("Reserve a Table"),
                ),
              ],
            ),
          ],
        ),
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Adjust alignment as needed
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showAddDialog(context);
                  },
                  child: const Text("Add Review"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ReservationFormPage extends StatelessWidget {
  final int restaurantId;

  const ReservationFormPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservation Form"),
      ),
      body: Center(
        child: Text("Reservation form for restaurant ID: $restaurantId"),
      ),
    );
  }

  List<Map<String, dynamic>> categories = [];
  bool showNewCategoryField = false;

  Future<void> fetchCategories(CookieRequest request) async {
    final response = await request
        .get("http://127.0.0.1:8000/wishlist/fetch-user-categories/");
    final List<dynamic> data = response;
    if (mounted) {
      setState(() {
        categories =
            data.map((e) => {'id': e['id'], 'name': e['name']}).toList();
      });
    }
  }

  void _addToWishlistDialog(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController newCategoryController = TextEditingController();
    final request = Provider.of<CookieRequest>(context, listen: false);

    await fetchCategories(request);
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add To Wishlist"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  DropdownButton<String>(
                    value: selectedCategory,
                    hint: const Text("Select a category"),
                    isExpanded: true,
                    items: [
                      ...categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'].toString(),
                          child: Text(category['name']),
                        );
                      }).toList(),
                      const DropdownMenuItem<String>(
                        value: 'new',
                        child: Text("Create a new category"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        showNewCategoryField = value == 'new';
                      });
                    },
                  ),
                  if (showNewCategoryField)
                    TextField(
                      controller: newCategoryController,
                      decoration:
                          const InputDecoration(labelText: "New Category Name"),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text;
                    final newCategory = newCategoryController.text;

                    try {
                      final response = await request.postJson(
                          "http://127.0.0.1:8000/wishlist/add-flutter/",
                          jsonEncode(<String, String?>{
                            'restaurant_id': restaurantID.toString(),
                            'title': title,
                            'category_id': selectedCategory == 'new'
                                ? null
                                : selectedCategory,
                            'new_category_name':
                                selectedCategory == 'new' ? newCategory : null,
                          }));

                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Added to wishlist!")),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to add.")),
                        );
                      }
                    } catch (e) {
                      print('Error adding to wishlist: $e');
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
