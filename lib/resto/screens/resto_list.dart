import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:steve_mobile/main/screens/steakhouse_page.dart';
import 'package:steve_mobile/resto/screens/resto_entryform.dart';
import 'package:steve_mobile/widgets/leftdrawer.dart';
import 'package:steve_mobile/resto/widgets/restaurant_card.dart';
import 'package:steve_mobile/resto/models/restaurant_entry.dart';
import 'package:steve_mobile/main/providers/user_provider.dart';
import 'dart:convert';
import 'package:steve_mobile/resto/screens/resto_editform,.dart';

class RestoListPage extends StatefulWidget {
  const RestoListPage({super.key});

  @override
  State<RestoListPage> createState() => _RestoListPageState();
}

class _RestoListPageState extends State<RestoListPage> {
  var _searchQuery = '';
  final _scrollController = ScrollController();

  // Define the primary color to match the website
  static const primaryColor = Color(0xFFDC1E2D); // Red color from website

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

  void _reserveClick(RestaurantEntry restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SteakhousePage(restaurant: restaurant),
      ),
    );
  }

  void _showDeleteConfirmation(
      RestaurantEntry restaurant, CookieRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Restaurant',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to delete ${restaurant.fields.name}?',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: primaryColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final response = await request.postJson(
                    'http://127.0.0.1:8000/resto/flutter/delete-resto/',
                    jsonEncode(<String, int>{
                      'id': restaurant.pk,
                    }));

                if (context.mounted) {
                  if (response['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully deleted restaurant'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    setState(() {
                      _searchQuery = _searchQuery;
                    });

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete restaurant'),
                        backgroundColor: Colors.red,
                      ),
                    );

                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Restaurant List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Restaurants',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchRestaurant(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No restaurants found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                List<RestaurantEntry> filteredRestaurants = [];
                for (var restaurant in snapshot.data) {
                  if (restaurant.fields.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase())) {
                    filteredRestaurants.add(restaurant);
                  }
                }

                if (filteredRestaurants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No restaurants match your search',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  color: primaryColor,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filteredRestaurants.length,
                    itemBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RestaurantCard(
                        restaurant: filteredRestaurants[index],
                        onDetailPressed: () =>
                            _reserveClick(filteredRestaurants[index]),
                        onEditPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return RestoEditEntryFormPage(
                                restaurant: filteredRestaurants[index],
                              );
                            }),
                          );
                        },
                        onDeletePressed: () => _showDeleteConfirmation(
                            filteredRestaurants[index], request),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: userProvider.isSuperuser
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const RestoEntryFormPage();
                  }),
                );
              },
              backgroundColor: primaryColor,
              icon: const Icon(Icons.add),
              label: const Text('Add Restaurant'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
    );
  }
}
