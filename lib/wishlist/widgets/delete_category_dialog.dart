import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

Future<void> showDeleteCategoryDialog(BuildContext context, String categoryName,
    String categoryId, CookieRequest request) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to delete the category "$categoryName"?'),
        actions: <Widget>[
          // Cancel button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          // Confirm button
          TextButton(
            onPressed: () async {
              try {
                final response = await request.postJson(
                  "http://127.0.0.1:8000/wishlist/delete-category-flutter/",
                  jsonEncode(<String, String?>{
                    'category_id': categoryId,
                  }),
                );
                if (response['message'] == 'Category deleted successfully') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Category deleted!")),
                  );
                  // Refresh the categories or perform any required action after delete
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to delete category.")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
