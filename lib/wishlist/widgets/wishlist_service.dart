import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:steve_mobile/wishlist/models/wishlist_product.dart';
import 'package:steve_mobile/resto/models/restaurant_entry.dart';

Future<WishlistProduct> fetchWishlist(CookieRequest request) async {
  final response =
      await request.get('http://danniel-steve.pbp.cs.ui.ac.id/wishlist/json/');
  return WishlistProduct.fromJson(response);
}

Future<List<RestaurantEntry>> fetchRestaurant(CookieRequest request) async {
  final response = await request.get(
      'http://danniel-steve.pbp.cs.ui.ac.id/resto/flutter/get-restaurants/');
  return (response as List).map((d) => RestaurantEntry.fromJson(d)).toList();
}
