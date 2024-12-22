import 'package:flutter/material.dart';
import 'package:steve_mobile/main/screens/steakhouse_page.dart'; 
import 'package:steve_mobile/resto/models/restaurant_entry.dart'; 

class ReservationCard extends StatelessWidget {
  final Map<String, String> reservation;
  final RestaurantEntry restaurant;
  final VoidCallback onCompletePressed;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const ReservationCard({
    Key? key,
    required this.reservation,
    required this.restaurant,
    required this.onCompletePressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          'Reservasi untuk ${reservation["name"]} pada ${reservation["date"]}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(restaurant.fields.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reservation["status"] == "active")
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: onCompletePressed,
                tooltip: 'Selesaikan Reservasi',
              ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEditPressed,
              tooltip: 'Edit Reservasi',
            ),
            if (reservation["status"] == "completed")
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDeletePressed,
                tooltip: 'Hapus Reservasi',
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
