// Create a new file called restaurant_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:steve_mobile/resto/models/restaurant_entry.dart';

import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'dart:convert';

class RestaurantDetailDialog extends StatefulWidget {
  final RestaurantEntry restaurant;
  static const primaryColor = Color(0xFFDC1E2D);

  const RestaurantDetailDialog({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailDialog> createState() => _RestaurantDetailDialogState();
}

class _RestaurantDetailDialogState extends State<RestaurantDetailDialog> {
  List<Map<String, dynamic>> categories = [];
  bool showNewCategoryField = false;
  static const primaryColor = Color(0xFFDC1E2D);

  Future<void> fetchCategories(CookieRequest request) async {
    final response = await request.get(
        "https://danniel-steve.pbp.cs.ui.ac.id/wishlist/fetch-user-categories/");
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
                      final response = await request.post(
                          "https://danniel-steve.pbp.cs.ui.ac.id/wishlist/add-flutter/",
                          jsonEncode(<String, String?>{
                            'restaurant_id': widget.restaurant.pk.toString(),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.restaurant.fields.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Operating Hours Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Operating Hours',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.restaurant.fields.openingTime} - ${widget.restaurant.fields.closingTime}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildInfoRow(Icons.location_on, 'Location:',
                  widget.restaurant.fields.location),
              const SizedBox(height: 16),

              _buildInfoRow(Icons.star, 'Rating:',
                  '${widget.restaurant.fields.rating}/5'),
              const SizedBox(height: 16),

              _buildInfoRow(Icons.attach_money, 'Average Price:',
                  'Rp.${widget.restaurant.fields.price.toString()}'),
              const SizedBox(height: 16),

              // Special Menu Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu,
                          size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Special Dishes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.restaurant.fields.specialMenu,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description,
                          size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.restaurant.fields.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reservation Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _addToWishlistDialog(context);
                  },
                  child: const Text(
                    'Add to Wishlist',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // Your existing build method and _buildInfoRow method here
}
