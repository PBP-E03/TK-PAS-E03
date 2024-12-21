import 'package:flutter/material.dart';

class EditWishlistDialog extends StatefulWidget {
  final String initialTitle;
  final int? initialCategory;
  final List<DropdownMenuItem<int?>> categoryItems;
  final void Function(String title, int? category, String? newCategoryName)
      onEdit;

  const EditWishlistDialog({
    Key? key,
    required this.initialTitle,
    required this.initialCategory,
    required this.categoryItems,
    required this.onEdit,
  }) : super(key: key);

  @override
  _EditWishlistDialogState createState() => _EditWishlistDialogState();
}

class _EditWishlistDialogState extends State<EditWishlistDialog> {
  late String title;
  late int? category;
  String? newCategoryName;
  bool showNewCategoryField = false;

  late TextEditingController titleController; // Declare it once here
  late TextEditingController newCategoryController;

  @override
  void initState() {
    super.initState();
    title = widget.initialTitle;
    category = widget.initialCategory;
    titleController =
        TextEditingController(text: title); // Initialize with initial value
    newCategoryController =
        TextEditingController(); // Initialize for new category field
  }

  @override
  void dispose() {
    titleController.dispose(); // Dispose controllers when widget is destroyed
    newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Wishlist Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text input for title
          TextField(
            controller: titleController, // Use the initialized controller
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                title = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Dropdown for category selection
          DropdownButtonFormField<int?>(
            value: category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            isExpanded: true,
            items: [
              ...widget.categoryItems,
              const DropdownMenuItem<int?>(
                value: -1, // Special value for "Create a new category"
                child: Text("Create a new category"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                category = value == -1 ? null : value;
                showNewCategoryField = value == -1;
              });
            },
          ),
          const SizedBox(height: 16),
          // Show new category input field if "Create a new category" is selected
          if (showNewCategoryField)
            TextField(
                controller: newCategoryController,
                decoration: const InputDecoration(
                  labelText: "New Category Name",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  newCategoryName = value;
                }),
        ],
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        // Submit button
        TextButton(
          onPressed: () {
            widget.onEdit(
              title,
              showNewCategoryField ? null : category,
              newCategoryName,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Edit'),
        ),
      ],
    );
  }
}
