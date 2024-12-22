import 'wishlist_category.dart';
import 'wishlist_item.dart';

class WishlistProduct {
  List<WishlistItem> wishlistItems;
  List<WishlistCategory> wishlistCategories;

  WishlistProduct({
    required this.wishlistItems,
    required this.wishlistCategories,
  });

  factory WishlistProduct.fromJson(Map<String, dynamic> json) =>
      WishlistProduct(
        wishlistItems: List<WishlistItem>.from(
            json["wishlist_items"].map((x) => WishlistItem.fromJson(x))),
        wishlistCategories: List<WishlistCategory>.from(
            json["wishlist_categories"]
                .map((x) => WishlistCategory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "wishlist_items":
            List<dynamic>.from(wishlistItems.map((x) => x.toJson())),
        "wishlist_categories":
            List<dynamic>.from(wishlistCategories.map((x) => x.toJson())),
      };
}
