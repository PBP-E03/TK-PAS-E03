import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import 'package:steve_mobile/review/models/review_entry.dart';

class ReviewsPage extends StatefulWidget {
  final int restaurantId;

  const ReviewsPage({super.key, required this.restaurantId});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<RatingEntry> reviews = [];
  bool isLoading = true;
  bool userHasReviewed = false; // Flag to check if the user has reviewed

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  // Function to fetch reviews from the server
  Future<void> fetchReviews() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await http.get(
        Uri.parse(
            'https://danniel-steve.pbp.cs.ui.ac.id/rating/flutter/get_rating/${widget.restaurantId}/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          reviews = data.map((review) => RatingEntry.fromJson(review)).toList();
          // Check if the logged-in user has already reviewed this restaurant
          userHasReviewed = reviews.any((review) =>
              review.fields.user.toString() == request.cookies['user_id']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Customer Reviews",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(review.fields.username),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Rating: ${review.fields.rating}"),
                                Text("Comment: ${review.fields.comment}"),
                                Text(
                                    "Date: ${formatDate(review.fields.createdAt)}"),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(context, review, request);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteReview(review.pk, request);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: userHasReviewed
                          ? null
                          : () {
                              _showAddDialog(context, request);
                            },
                      child: userHasReviewed
                          ? const Text(
                              "You have already reviewed this restaurant")
                          : const Text("Add Review"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Dialog to add a new review
  void _showAddDialog(BuildContext context, CookieRequest request) {
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
                  _addReview(textController.text, rating, request);
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog(
                      context, 'Please enter a valid rating (0-5).');
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Add review function
  Future<void> _addReview(
      String comment, int rating, CookieRequest request) async {
    final payload = {
      "restaurant": widget.restaurantId,
      "rating": rating,
      "comment": comment,
    };

    final response = await request.postJson(
      'https://danniel-steve.pbp.cs.ui.ac.id/rating/flutter/add_review/${widget.restaurantId}/',
      json.encode(payload),
    );

    if (response['status'] == 'success') {
      // Refresh the reviews after adding
      setState(() {
        fetchReviews(); // Refresh the reviews list
      });
    } else {
      _showErrorDialog(context,
          'Failed to add review: ${response['error'] ?? 'Unknown error'}');
    }
  }

  // Edit review dialog
  void _showEditDialog(
      BuildContext context, RatingEntry review, CookieRequest request) {
    final TextEditingController textController =
        TextEditingController(text: review.fields.comment);
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
                  _editReview(review.pk, textController.text, rating, request);
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog(
                      context, 'Please enter a valid rating (0-5).');
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // Edit review API call
  Future<void> _editReview(
      int reviewId, String comment, int rating, CookieRequest request) async {
    final response = await request.postJson(
      'https://danniel-steve.pbp.cs.ui.ac.id/rating/flutter/edit_review/$reviewId/',
      json.encode({
        "rating": rating,
        "comment": comment,
      }),
    );

    if (response['status'] == 'success') {
      // Refresh the reviews after editing
      setState(() {
        fetchReviews(); // Refresh the reviews list
      });
    } else {
      _showErrorDialog(context,
          'Failed to edit review: ${response['error'] ?? 'Unknown error'}');
    }
  }

  // Delete review function
  Future<void> _deleteReview(int reviewId, CookieRequest request) async {
    final response = await request.postJson(
      'https://danniel-steve.pbp.cs.ui.ac.id/rating/flutter/delete_review/$reviewId/',
      json.encode({}),
    );

    if (response['status'] == 'success') {
      // Refresh the reviews after deleting
      setState(() {
        fetchReviews(); // Refresh the reviews list
      });
    } else {
      _showErrorDialog(context,
          'Failed to delete review: ${response['error'] ?? 'Unknown error'}');
    }
  }

  // Show SnackBar with the given message
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute:$second';
  }
}
