import 'package:flutter/material.dart';
import 'package:steve_mobile/wishlist/models/wishlist_item.dart';
import 'package:steve_mobile/resto/models/restaurant_entry.dart';

class WishlistItemCard extends StatelessWidget {
  final WishlistItem item;
  final RestaurantEntry restaurant;
  final VoidCallback onTap;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const WishlistItemCard({
    Key? key,
    required this.item,
    required this.restaurant,
    required this.onTap,
    required this.onEditPressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(item.fields.title),
              subtitle: Text('Restaurant: ${restaurant.fields.name}'),
              trailing: Text(
                'Created: ${item.fields.createdAt}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              onTap: onTap,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: onEditPressed,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDeletePressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
