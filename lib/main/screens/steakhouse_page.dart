import 'package:flutter/material.dart';
import '../../review/review_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

// Models
import 'package:steve_mobile/resto/models/restaurant_entry.dart';

class SteakhousePage extends StatefulWidget {
  // final String steakhouseName;
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

  // Add a review
  void addReview(String text, int rating) {
    setState(() {
      reviews.add(
        ReviewEntry(
          model: "review",
          pk: DateTime.now().millisecondsSinceEpoch.toString(),
          fields: ReviewFields(
            user: 0, // Replace with actual user ID when login is implemented
            reviewerName: "test", // Placeholder for logged-in user
            text: text,
            rating: rating,
            date: DateTime.now(),
          ),
        ),
      );
    });
  }

  // Edit a review
  void editReview(String pk, String newText, int newRating) {
    setState(() {
      int index = reviews.indexWhere((review) => review.pk == pk);
      if (index != -1) {
        ReviewEntry oldReview = reviews[index];
        reviews[index] = ReviewEntry(
          model: oldReview.model,
          pk: oldReview.pk,
          fields: ReviewFields(
            user: oldReview.fields.user,
            reviewerName: oldReview.fields.reviewerName,
            text: newText,
            rating: newRating,
            date: oldReview.fields.date,
          ),
        );
      }
    });
  }

  // Delete a review
  void deleteReview(String pk) {
    setState(() {
      reviews.removeWhere((review) => review.pk == pk);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(steakhouseName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(review.fields.reviewerName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(review.fields.text),
                        Text("Rating: ${review.fields.rating.toString()}"),
                        Text(
                            "Date: ${review.fields.date.toLocal().toString().split(' ')[0]}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(context, review);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteReview(review.pk);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
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

  // Dialog to add a new review
  void _showAddDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final TextEditingController ratingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Review"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(labelText: "Review Text"),
              ),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(labelText: "Rating (0-5)"),
                keyboardType: TextInputType.number,
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
              onPressed: () {
                int? rating = int.tryParse(ratingController.text);
                if (rating != null && rating >= 0 && rating <= 5) {
                  addReview(textController.text, rating);
                  Navigator.of(context).pop();
                } else {
                  // Show an error if the rating is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid rating (0-5)."),
                    ),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Dialog to edit an existing review
  void _showEditDialog(BuildContext context, ReviewEntry review) {
    final TextEditingController textController =
        TextEditingController(text: review.fields.text);
    final TextEditingController ratingController =
        TextEditingController(text: review.fields.rating.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Review"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(labelText: "Review Text"),
              ),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(labelText: "Rating (0-5)"),
                keyboardType: TextInputType.number,
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
              onPressed: () {
                int? rating = int.tryParse(ratingController.text);
                if (rating != null && rating >= 0 && rating <= 5) {
                  editReview(review.pk, textController.text, rating);
                  Navigator.of(context).pop();
                } else {
                  // Show an error if the rating is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid rating (0-5)."),
                    ),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
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
