import 'package:flutter/material.dart';
import 'package:steve_mobile/wishlist/models/wishlist_product.dart';

class CategoryDropdown extends StatelessWidget {
  final WishlistProduct wishlistProduct;
  final ValueChanged<int?> onCategoryChanged;

  const CategoryDropdown({
    Key? key,
    required this.wishlistProduct,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButton<int?>(
        hint: const Text("Select Category"),
        isExpanded: true,
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text("All Categories"),
          ),
          ...wishlistProduct.wishlistCategories.map((category) {
            return DropdownMenuItem<int?>(
              value: category.pk,
              child: Text(category.fields.name),
            );
          }).toList(),
        ],
        onChanged: onCategoryChanged,
      ),
    );
  }
}
