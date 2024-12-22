import 'package:flutter/material.dart';

// Models
import 'package:steve_mobile/resto/models/restaurant_entry.dart';
import 'package:steve_mobile/review/screens/review_page.dart';

// Pages
import 'package:steve_mobile/reservasion/screens/reservation_screens.dart';

class SteakhousePage extends StatelessWidget {
  final RestaurantEntry restaurant;

  const SteakhousePage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.fields.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant.fields.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Location: ${restaurant.fields.location}"),
            Text("Price: \$${restaurant.fields.price}"),
            Text("Rating: ${restaurant.fields.rating}"),
            const SizedBox(height: 16),
            Text("Description:"),
            Text(restaurant.fields.description),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to reviews page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReviewsPage(restaurantId: restaurant.pk),
                      ),
                    );
                  },
                  child: const Text("View Reviews"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to reservation form
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationPage(),
                      ),
                    );
                  },
                  child: const Text("Reserve a Table"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class ReservationFormPage extends StatelessWidget {
//   final int restaurantId;

//   const ReservationFormPage({super.key, required this.restaurantId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Reservation Form"),
//       ),
//       body: Center(
//         child: Text("Reservation form for restaurant ID: $restaurantId"),
//       ),
//     );
//   }
// }
