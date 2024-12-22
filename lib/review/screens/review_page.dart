import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:steve_mobile/review/models/review_entry.dart';

class ReviewsPage extends StatefulWidget {
  final int restaurantId;

  const ReviewsPage({super.key, required this.restaurantId});

  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<RatingEntry> reviews = [];
  bool isLoading = true;
  String errorMessage = ''; // To hold error messages

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {     
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/rating/flutter/get_rating/${widget.restaurantId}/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          reviews = data.map((review) => RatingEntry.fromJson(review)).toList();
          isLoading = false;
        });
      } else {
        // Handle non-200 status codes
        setState(() {
          errorMessage = 'Failed to load reviews: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle unexpected errors (e.g., network issues)
      setState(() {
        errorMessage = 'Error loading reviews: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage)) // Display error message
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
                                title: Text(review.fields.user.toString()),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Rating: ${review.fields.rating}"),
                                    Text("Comment: ${review.fields.comment}"),
                                    Text("Date: ${review.fields.createdAt}"),
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
                                        _deleteReview(review.pk); 
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
                          onPressed: () {
                            _showAddDialog(context);
                          },
                          child: const Text("Add Review"),
                        ),
                      ),
                    ],
                  ),
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
                  _addReview(textController.text, rating);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a valid rating (0-5).")),
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

  // Add review function
  Future<void> _addReview(String comment, int rating) async {
    final session = Provider.of<CookieRequest>(context);
    final userId = await session.get("user_id");

    final payload = {
      "restaurant": widget.restaurantId,
      "user": userId.toString(),
      "rating": rating,
      "comment": comment,
    };

    print(payload);

    try {
      final response = await session.postJson(
        'http://127.0.0.1:8000/rating/flutter/add_review/${widget.restaurantId}/',
        payload,
      );

      if (response.statusCode == 201) {
        fetchReviews(); // Refresh the reviews after adding
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add review: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add review. Please try again later.')),
      );
    }
  }

  // Edit review dialog
  void _showEditDialog(BuildContext context, RatingEntry review) {
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
                  _editReview(review.pk, textController.text, rating);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a valid rating (0-5).")),
                  );
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
  Future<void> _editReview(int reviewId, String comment, int rating) async {
    final session = Provider.of<CookieRequest>(context, listen: false);
    final userId = await session.get("user_id");

    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/rating/flutter/edit_review/$reviewId/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "user": userId.toString(),
        "rating": rating,
        "comment": comment,
      }),
    );

    if (response.statusCode == 200) {
      fetchReviews(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to edit review")),
      );
    }
  }

  // Delete review function
  Future<void> _deleteReview(int reviewId) async {
    final session = Provider.of<CookieRequest>(context, listen: false);
    final userId = session.get("user_id");

    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/rating/flutter/delete_review/$reviewId/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "user": userId.toString(),
      }),
    );

    if (response.statusCode == 200) {
      fetchReviews(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete review")),
      );
    }
  }
}
