import 'package:flutter/material.dart';
import 'package:steve_mobile/review/review_entry.dart';

class ReviewsPage extends StatefulWidget {
  final String steakhouseName;

  const ReviewsPage({Key? key, required this.steakhouseName}) : super(key: key);

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<ReviewEntry> reviews = List.from(dummyReviews); // Simulated review data
  int currentUserId = 1; // Replace with the logged-in user's ID

  // Add a review
  void addReview(String text, int rating) {
    if (reviews.any((review) => review.fields.user == currentUserId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can only leave one review per steakhouse."),
        ),
      );
    } else {
      setState(() {
        reviews.add(
          ReviewEntry(
            model: "review",
            pk: DateTime.now().millisecondsSinceEpoch.toString(),
            fields: ReviewFields(
              user: currentUserId, // Use the logged-in user's ID
              reviewerName: "test", // Placeholder for logged-in user
              text: text,
              rating: rating,
              date: DateTime.now(),
            ),
          ),
        );
      });
    }
  }

  // Edit a review
  void editReview(String pk, String newText, int newRating) {
    setState(() {
      int index = reviews.indexWhere((review) => review.pk == pk);
      if (index != -1 && reviews[index].fields.user == currentUserId) {
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You can only edit your own reviews."),
          ),
        );
      }
    });
  }

  // Delete a review
  void deleteReview(String pk) {
    setState(() {
      int index = reviews.indexWhere((review) => review.pk == pk);
      if (index != -1 && reviews[index].fields.user == currentUserId) {
        reviews.removeAt(index);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You can only delete your own reviews."),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews for ${widget.steakhouseName}"),
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
                        // Edit button only if it's the user's review
                        if (review.fields.user == currentUserId)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditDialog(context, review);
                            },
                          ),
                        // Delete button only if it's the user's review
                        if (review.fields.user == currentUserId)
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
    );
  }

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
}