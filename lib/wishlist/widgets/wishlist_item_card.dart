import 'package:flutter/material.dart';
import 'package:steve_mobile/main/screens/steakhouse_page.dart';
import 'package:steve_mobile/wishlist/models/wishlist_item.dart';
import 'package:steve_mobile/resto/models/restaurant_entry.dart';

class WishlistItemCard extends StatelessWidget {
  final WishlistItem item;
  final RestaurantEntry restaurant;
  final VoidCallback onDeletePressed;
  final VoidCallback onEditPressed; // Add this line

  const WishlistItemCard({
    Key? key,
    required this.item,
    required this.restaurant,
    required this.onDeletePressed,
    required this.onEditPressed, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(item.fields.title),
        subtitle: Text(restaurant.fields.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEditPressed, // Use the edit callback
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDeletePressed,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SteakhousePage(restaurant: restaurant),
            ),
          );
        },
      ),
    );
  }
}
