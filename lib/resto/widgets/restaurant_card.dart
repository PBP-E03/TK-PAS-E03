import 'package:flutter/material.dart';
import 'package:steve_mobile/resto/models/restaurant_entry.dart';

// Provider
import 'package:provider/provider.dart';
import 'package:steve_mobile/main/providers/user_provider.dart';

// Widget
import 'package:steve_mobile/resto/widgets/restaurant_detail.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantEntry restaurant;
  final VoidCallback? onDetailPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onDetailPressed,
    this.onEditPressed,
    this.onDeletePressed,
  });

  String ratingStar(int rating) {
    String star = '';
    for (int i = 0; i < rating; i++) {
      star += '⭐';
    }
    return star;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    void _showDetailDialog(RestaurantEntry restaurant) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return RestaurantDetailDialog(restaurant: restaurant);
        },
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder image (you can replace with network image later)
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
              child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showDetailDialog(restaurant),
                    child: Text(
                      restaurant.fields.name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Location: ${restaurant.fields.location}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rating: ${ratingStar(restaurant.fields.rating)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Price: Rp.${restaurant.fields.price}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: onDetailPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reserve'),
                      ),
                      const SizedBox(width: 8),
                      if (userProvider.isSuperuser) ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: onEditPressed,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDeletePressed,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
