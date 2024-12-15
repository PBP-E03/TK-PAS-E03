import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Screens
import 'package:steve_mobile/main/screens/steakhouse_page.dart';

// Widgets
import 'package:steve_mobile/widgets/leftdrawer.dart';
import 'package:steve_mobile/resto/widgets/restaurant_card.dart';

// Model
import 'package:steve_mobile/resto/models/restaurant_entry.dart';

class RestoListPage extends StatefulWidget {
  const RestoListPage({super.key});

  @override
  State<RestoListPage> createState() => _RestoListPageState();
}

class _RestoListPageState extends State<RestoListPage> {
  var _searchQuery = '';

  Future<List<RestaurantEntry>> fetchRestaurant(CookieRequest request) async {
    final response = await request
        .get('http://127.0.0.1:8000/resto/flutter/get-restaurants/');

    // Decode to JSON
    var data = response;

    // Convert JSON to List of RestaurantEntry
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

  void _showDeleteConfirmation(RestaurantEntry restaurant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Restaurant'),
          content: Text(
              'Are you sure you want to delete ${restaurant.fields.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // TODO: Implement delete functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${restaurant.fields.name} deleted')),
                );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant List'),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Restaurants',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
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
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No Data'));
                  } else {
                    // Filter restaurants based on search query

                    List<RestaurantEntry> filteredRestaurants = [];
                    for (var restaurant in snapshot.data) {
                      if (restaurant.fields.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase())) {
                        filteredRestaurants.add(restaurant);
                      }
                    }

                    return ListView.builder(
                      itemCount: filteredRestaurants.length,
                      itemBuilder: (_, index) => RestaurantCard(
                        restaurant: filteredRestaurants[index],
                        onDetailPressed: () =>
                            _reserveClick(filteredRestaurants[index]),
                        onEditPressed: () {
                          // TODO: Implement edit functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Edit ${filteredRestaurants[index].fields.name}')),
                          );
                        },
                        onDeletePressed: () =>
                            _showDeleteConfirmation(filteredRestaurants[index]),
                      ),
                    );
                  }
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
