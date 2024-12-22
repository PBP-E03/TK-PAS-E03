import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:steve_mobile/wishlist/models/wishlist_product.dart';
import 'package:steve_mobile/resto/models/restaurant_entry.dart';

Future<WishlistProduct> fetchWishlist(CookieRequest request) async {
  final response = await request.get('http://127.0.0.1:8000/wishlist/json/');
  return WishlistProduct.fromJson(response);
}

Future<List<RestaurantEntry>> fetchRestaurant(CookieRequest request) async {
  final response =
      await request.get('http://127.0.0.1:8000/resto/flutter/get-restaurants/');
  return (response as List).map((d) => RestaurantEntry.fromJson(d)).toList();
}
