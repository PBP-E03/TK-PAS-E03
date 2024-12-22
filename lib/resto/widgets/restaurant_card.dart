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
  static const primaryColor = Color(0xFFDC1E2D);

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onDetailPressed,
    this.onEditPressed,
    this.onDeletePressed,
  });

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
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDetailDialog(restaurant),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 300;

            return Row(
              children: [
                // Image container
                Container(
                  width: isWide ? 120 : 100,
                  height: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(
                    child:
                        Icon(Icons.restaurant, size: 40, color: primaryColor),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.fields.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (userProvider.isSuperuser && isWide)
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: onEditPressed,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: onDeletePressed,
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.fields.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rp.${restaurant.fields.price}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                            ),
                            TextButton(
                              onPressed: onDetailPressed,
                              style: TextButton.styleFrom(
                                foregroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                minimumSize: const Size(60, 32),
                              ),
                              child: const Text('Reserve'),
                            ),
                          ],
                        ),
                        if (userProvider.isSuperuser && !isWide)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: onEditPressed,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: onDeletePressed,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
