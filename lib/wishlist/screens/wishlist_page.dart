import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:steve_mobile/widgets/leftdrawer.dart';
import 'package:steve_mobile/wishlist/models/wishlist_category.dart';
import 'package:steve_mobile/wishlist/models/wishlist_item.dart';
import 'package:steve_mobile/wishlist/models/wishlist_product.dart';
import 'package:steve_mobile/resto/models/restaurant_entry.dart';
import 'package:steve_mobile/wishlist/widgets/edit_dialog.dart';
import 'package:steve_mobile/wishlist/widgets/wishlist_service.dart';
import 'package:steve_mobile/wishlist/widgets/category_dropdown.dart';
import 'package:steve_mobile/wishlist/widgets/wishlist_item_card.dart';
import 'package:steve_mobile/wishlist/widgets/delete_confirmation_dialog.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late List<WishlistItem> filteredItems;
  int? selectedCategory;
  List<RestaurantEntry> restaurantEntries = [];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      drawer: const LeftDrawer(),
      body: FutureBuilder<WishlistProduct>(
        future: fetchWishlist(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16, color: Colors.red)));
          } else if (!snapshot.hasData ||
              snapshot.data!.wishlistCategories.isEmpty &&
                  snapshot.data!.wishlistItems.isEmpty) {
            return const Center(
                child: Text('No wishlist data available.',
                    style: TextStyle(fontSize: 18, color: Colors.black54)));
          }

          final wishlistProduct = snapshot.data!;
          return FutureBuilder<List<RestaurantEntry>>(
            future: fetchRestaurant(request),
            builder: (context, restaurantSnapshot) {
              if (restaurantSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (restaurantSnapshot.hasError) {
                return Center(
                    child: Text(
                        'Error fetching restaurants: ${restaurantSnapshot.error}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.red)));
              } else if (!restaurantSnapshot.hasData ||
                  restaurantSnapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No restaurant data available.',
                        style: TextStyle(fontSize: 18, color: Colors.black54)));
              }

              restaurantEntries = restaurantSnapshot.data!;
              return Column(
                children: [
                  CategoryDropdown(
                    wishlistProduct: wishlistProduct,
                    onCategoryChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        filteredItems = selectedCategory == null
                            ? wishlistProduct.wishlistItems
                            : wishlistProduct.wishlistItems
                                .where((item) =>
                                    item.fields.wishlistCategory ==
                                    selectedCategory)
                                .toList();
                      });
                    },
                  ),
                  Expanded(
                    child: ListView(
                      children: selectedCategory == null
                          ? _buildCategories(wishlistProduct)
                          : _buildFilteredItems(filteredItems),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildCategories(WishlistProduct wishlistProduct) {
    return wishlistProduct.wishlistCategories.map((category) {
      final itemsInCategory = wishlistProduct.wishlistItems
          .where((item) => item.fields.wishlistCategory == category.pk)
          .toList();
      if (itemsInCategory.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(category),
          ...itemsInCategory
              .map((item) => WishlistItemCard(
                  item: item,
                  restaurant: restaurantEntries.firstWhere(
                      (entry) => entry.pk == item.fields.restaurant),
                  onDeletePressed: () {
                    _showDeleteConfirmationDialog(item);
                  },
                  onEditPressed: () {
                    _showEditDialog(
                        item, wishlistProduct); // Call the edit dialog here
                  }))
              .toList(),
        ],
      );
    }).toList();
  }

  List<Widget> _buildFilteredItems(List<WishlistItem> filteredItems) {
    return filteredItems.map((item) {
      final restaurant = restaurantEntries.firstWhere(
        (entry) => entry.pk == item.fields.restaurant,
        orElse: () => throw Exception('Restaurant not found'),
      );

      return WishlistItemCard(
        item: item,
        restaurant: restaurant,
        onDeletePressed: () {
          _showDeleteConfirmationDialog(item);
        },
        onEditPressed: () {
          _showEditDialog(item,
              context.read<WishlistProduct>()); // Call the edit dialog here
        },
      );
    }).toList();
  }

  Widget _buildCategoryHeader(WishlistCategory category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category.fields.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialogForCategory(category);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(WishlistItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          title: item.fields.title,
          onConfirm: () async {
            await _deleteWishlistItem(item.pk);
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialogForCategory(WishlistCategory category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          title: category.fields.name,
          onConfirm: () async {
            await _deleteCategory(category.pk);
          },
        );
      },
    );
  }

  Future<void> _deleteWishlistItem(int itemId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
        "http://127.0.0.1:8000/wishlist/delete-flutter/",
        jsonEncode({'wishlist_id': itemId.toString()}),
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Wishlist item deleted!")));
        final wishlistProduct = await fetchWishlist(request);
        setState(() {
          filteredItems = selectedCategory == null
              ? wishlistProduct.wishlistItems
              : wishlistProduct.wishlistItems
                  .where((item) =>
                      item.fields.wishlistCategory == selectedCategory)
                  .toList();
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to delete.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _deleteCategory(int categoryId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
        "http://127.0.0.1:8000/wishlist/delete-category-flutter/",
        jsonEncode({'category_id': categoryId.toString()}),
      );
      if (response['message'] == 'Category deleted successfully') {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Category deleted!")));
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to delete category.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _editWishlistItem(int itemId, String editedTitle,
      int? editedCategory, String newCategoryName) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
        "http://127.0.0.1:8000/wishlist/edit-flutter/",
        jsonEncode(<String, String?>{
          'wishlist_id': itemId.toString(),
          'title': editedTitle,
          'category_id': editedCategory?.toString(),
          'new_category_name': editedCategory == null ? newCategoryName : null,
        }),
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Wishlist item updated!")));
        final wishlistProduct = await fetchWishlist(request);
        setState(() {
          filteredItems = selectedCategory == null
              ? wishlistProduct.wishlistItems
              : wishlistProduct.wishlistItems
                  .where((item) =>
                      item.fields.wishlistCategory == selectedCategory)
                  .toList();
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to update.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showEditDialog(WishlistItem item, WishlistProduct wishlistProduct) {
    showDialog(
      context: context,
      builder: (context) {
        return EditWishlistDialog(
          initialTitle: item.fields.title,
          initialCategory: item.fields.wishlistCategory,
          categoryItems: wishlistProduct.wishlistCategories
              .map((category) => DropdownMenuItem<int?>(
                    value: category.pk,
                    child: Text(category.fields.name),
                  ))
              .toList(),
          onEdit: (title, category, newCategoryName) async {
            await _editWishlistItem(
                item.pk, title, category, newCategoryName ?? '');
          },
        );
      },
    );
  }
}
