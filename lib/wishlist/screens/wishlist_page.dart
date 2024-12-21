import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:steve_mobile/main/screens/steakhouse_page.dart';
import 'package:steve_mobile/wishlist/models/wishlist_item.dart';
import 'package:steve_mobile/wishlist/models/wishlist_product.dart';
import 'package:steve_mobile/widgets/leftdrawer.dart';
import 'package:steve_mobile/resto/models/restaurant_entry.dart';
import 'package:steve_mobile/wishlist/widgets/edit_dialog.dart';
import 'package:steve_mobile/wishlist/widgets/wishlist_card.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late List<WishlistItem> filteredItems;
  int? selectedCategory;

  // List to hold restaurant data
  List<RestaurantEntry> restaurantEntries = [];

  // Fetch wishlist data from the server
  Future<WishlistProduct> fetchWishlist(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/wishlist/json/');
    return WishlistProduct.fromJson(response);
  }

  // Fetch restaurant data from the server
  Future<List<RestaurantEntry>> fetchRestaurant(CookieRequest request) async {
    final response = await request
        .get('http://127.0.0.1:8000/resto/flutter/get-restaurants/');
    var data = response;
    List<RestaurantEntry> listRestaurant = [];
    for (var d in data) {
      if (d != null) {
        listRestaurant.add(RestaurantEntry.fromJson(d));
      }
    }
    return listRestaurant;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<WishlistProduct>(
        future: fetchWishlist(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData ||
              snapshot.data!.wishlistCategories.isEmpty &&
                  snapshot.data!.wishlistItems.isEmpty) {
            return const Center(
              child: Text(
                'No wishlist data available.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
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
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                );
              } else if (!restaurantSnapshot.hasData ||
                  restaurantSnapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No restaurant data available.',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                );
              }

              restaurantEntries = restaurantSnapshot.data!;
              return Column(
                children: [
                  // Category filter dropdown
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton<int?>(
                      hint: const Text("Select Category"),
                      value: selectedCategory,
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
                      onChanged: (value) {
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
                  ),

                  // Display filtered wishlist items based on selected category
                  Expanded(
                    child: ListView(
                      children: selectedCategory == null
                          ? wishlistProduct.wishlistCategories.map((category) {
                              // Get items for the category
                              final itemsInCategory = wishlistProduct
                                  .wishlistItems
                                  .where((item) =>
                                      item.fields.wishlistCategory ==
                                      category.pk)
                                  .toList();

                              // If no items, skip rendering this category
                              if (itemsInCategory.isEmpty) {
                                return const SizedBox
                                    .shrink(); // Return empty space if no items
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category Title with Delete Button
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          category.fields.name,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            // Show delete confirmation dialog
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Confirm Deletion'),
                                                  content: Text(
                                                      'Are you sure you want to delete the category "${category.fields.name}"?'),
                                                  actions: <Widget>[
                                                    // Cancel button
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    // Confirm button
                                                    TextButton(
                                                      onPressed: () async {
                                                        try {
                                                          final response =
                                                              await request
                                                                  .postJson(
                                                            "http://127.0.0.1:8000/wishlist/delete-category-flutter/",
                                                            jsonEncode(<String,
                                                                String?>{
                                                              'category_id':
                                                                  category.pk
                                                                      .toString(),
                                                            }),
                                                          );
                                                          if (response[
                                                                  'message'] ==
                                                              'Category deleted successfully') {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      "Category deleted!")),
                                                            );
                                                            setState(() {});
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      "Failed to delete category.")),
                                                            );
                                                          }
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    "Error: $e")),
                                                          );
                                                        }
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child:
                                                          const Text('Delete'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Items in the Category
                                  ...itemsInCategory.map((item) {
                                    final restaurant =
                                        restaurantEntries.firstWhere(
                                      (entry) =>
                                          entry.pk == item.fields.restaurant,
                                      orElse: () => throw Exception(
                                          'Restaurant not found'),
                                    );

                                    return WishlistItemCard(
                                      item: item,
                                      restaurant: restaurant,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SteakhousePage(
                                                    restaurant: restaurant),
                                          ),
                                        );
                                      },
                                      onEditPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              EditWishlistDialog(
                                            initialTitle: item.fields.title,
                                            initialCategory:
                                                item.fields.wishlistCategory,
                                            categoryItems: wishlistProduct
                                                .wishlistCategories
                                                .map((category) {
                                              return DropdownMenuItem<int?>(
                                                value: category.pk,
                                                child:
                                                    Text(category.fields.name),
                                              );
                                            }).toList(),
                                            onEdit: (editedTitle,
                                                editedCategory,
                                                newCategoryName) async {
                                              try {
                                                final response =
                                                    await request.postJson(
                                                  "http://127.0.0.1:8000/wishlist/edit-flutter/",
                                                  jsonEncode(<String, String?>{
                                                    'wishlist_id':
                                                        item.pk.toString(),
                                                    'title': editedTitle,
                                                    'category_id':
                                                        editedCategory
                                                            ?.toString(),
                                                    'new_category_name':
                                                        editedCategory == null
                                                            ? newCategoryName
                                                            : null,
                                                  }),
                                                );

                                                if (response['status'] ==
                                                    'success') {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            "Wishlist item updated!")),
                                                  );
                                                  setState(() {
                                                    filteredItems = selectedCategory ==
                                                            null
                                                        ? wishlistProduct
                                                            .wishlistItems
                                                        : wishlistProduct
                                                            .wishlistItems
                                                            .where((item) =>
                                                                item.fields
                                                                    .wishlistCategory ==
                                                                selectedCategory)
                                                            .toList();
                                                  });
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            "Failed to update.")),
                                                  );
                                                }
                                              } catch (e) {
                                                print(
                                                    'Error updating wishlist: $e');
                                              }
                                            },
                                          ),
                                        );
                                      },
                                      onDeletePressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Confirm Deletion'),
                                              content: Text(
                                                  'Are you sure you want to delete "${item.fields.title}" from your wishlist?'),
                                              actions: <Widget>[
                                                // Cancel button
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                // Confirm button
                                                TextButton(
                                                  onPressed: () async {
                                                    try {
                                                      final response =
                                                          await request
                                                              .postJson(
                                                        "http://127.0.0.1:8000/wishlist/delete-flutter/",
                                                        jsonEncode(<String,
                                                            String?>{
                                                          'wishlist_id': item.pk
                                                              .toString(),
                                                        }),
                                                      );
                                                      if (response['status'] ==
                                                          'success') {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                              content: Text(
                                                                  "Wishlist item deleted!")),
                                                        );
                                                        setState(() {
                                                          filteredItems = selectedCategory ==
                                                                  null
                                                              ? wishlistProduct
                                                                  .wishlistItems
                                                              : wishlistProduct
                                                                  .wishlistItems
                                                                  .where((item) =>
                                                                      item.fields
                                                                          .wishlistCategory ==
                                                                      selectedCategory)
                                                                  .toList();
                                                        });
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                              content: Text(
                                                                  "Failed to delete.")),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                "Error: $e")),
                                                      );
                                                    }
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }).toList(),
                                ],
                              );
                            }).toList()
                          : filteredItems.map((item) {
                              final restaurant = restaurantEntries.firstWhere(
                                (entry) => entry.pk == item.fields.restaurant,
                                orElse: () =>
                                    throw Exception('Restaurant not found'),
                              );

                              return WishlistItemCard(
                                item: item,
                                restaurant: restaurant,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SteakhousePage(
                                        restaurant: restaurant,
                                      ),
                                    ),
                                  );
                                },
                                onEditPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => EditWishlistDialog(
                                      initialTitle: item.fields.title,
                                      initialCategory:
                                          item.fields.wishlistCategory,
                                      categoryItems: wishlistProduct
                                          .wishlistCategories
                                          .map((category) {
                                        return DropdownMenuItem<int?>(
                                          value: category.pk,
                                          child: Text(category.fields.name),
                                        );
                                      }).toList(),
                                      onEdit: (editedTitle, editedCategory,
                                          newCategoryName) async {
                                        try {
                                          final response =
                                              await request.postJson(
                                            "http://127.0.0.1:8000/wishlist/edit-flutter/",
                                            jsonEncode(<String, String?>{
                                              'wishlist_id': item.pk.toString(),
                                              'title': editedTitle,
                                              'category_id':
                                                  editedCategory?.toString(),
                                              'new_category_name':
                                                  editedCategory == null
                                                      ? newCategoryName
                                                      : null,
                                            }),
                                          );

                                          if (response['status'] == 'success') {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Wishlist item updated!")),
                                            );
                                            setState(() {
                                              filteredItems = selectedCategory ==
                                                      null
                                                  ? wishlistProduct
                                                      .wishlistItems
                                                  : wishlistProduct
                                                      .wishlistItems
                                                      .where((item) =>
                                                          item.fields
                                                              .wishlistCategory ==
                                                          selectedCategory)
                                                      .toList();
                                            });
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Failed to update.")),
                                            );
                                          }
                                        } catch (e) {
                                          print('Error updating wishlist: $e');
                                        }
                                      },
                                    ),
                                  );
                                },
                                onDeletePressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: Text(
                                            'Are you sure you want to delete "${item.fields.title}" from your wishlist?'),
                                        actions: <Widget>[
                                          // Cancel button
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          // Confirm button
                                          TextButton(
                                            onPressed: () async {
                                              try {
                                                final response =
                                                    await request.postJson(
                                                  "http://127.0.0.1:8000/wishlist/delete-flutter/",
                                                  jsonEncode(<String, String?>{
                                                    'wishlist_id':
                                                        item.pk.toString(),
                                                  }),
                                                );
                                                if (response['status'] ==
                                                    'success') {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            "Wishlist item deleted!")),
                                                  );
                                                  setState(() {
                                                    filteredItems = selectedCategory ==
                                                            null
                                                        ? wishlistProduct
                                                            .wishlistItems
                                                        : wishlistProduct
                                                            .wishlistItems
                                                            .where((item) =>
                                                                item.fields
                                                                    .wishlistCategory ==
                                                                selectedCategory)
                                                            .toList();
                                                  });
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            "Failed to delete.")),
                                                  );
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content:
                                                          Text("Error: $e")),
                                                );
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            }).toList(),
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
}
