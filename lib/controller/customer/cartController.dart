import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/cartModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  final baseUrl = AppConstants.baseUrl; // Replace with your backend URL

Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('Retrieved token: $token');  // Debug print
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

   void clearCart() {
    cartItems.clear();
    update(); // Notify listeners
  }
  

  Future<void> addToCart(int artworkId, {int quantity = 1}) async {
  final token = await _getToken();
  if (token == null) {
    Get.snackbar("Error", "Please login first");
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'artwork_id': artworkId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Added to cart: ${responseData['artwork_title']}');
      print('Image URL: ${responseData['artwork_image']}');
      await fetchCartItems();
      Get.snackbar("Success", "Item added to cart");
    } else {
      final error = jsonDecode(response.body)['error'] ?? "Failed to add to cart";
      Get.snackbar("Error", error);
    }
  } catch (e) {
    Get.snackbar("Error", "Network error: ${e.toString()}");
  }
}

  Future<void> fetchCartItems() async {
  final token = await _getToken();
  if (token == null || token.isEmpty) {
    Get.snackbar("Error", "Not authenticated");
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/cart/'),
      headers: {
        'Authorization': 'Token $token', // Add this header
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      print("cart data ================  $data");
      cartItems.value = data.map((item) => CartItem.fromJson(item)).toList();
    } else {
      print('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('Network error: $e');
  }
}

  Future<void> removeFromCart(int artworkId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/cart/remove/');
    final res = await http.post(url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'artwork_id': artworkId}),
    );
    if (res.statusCode == 200) {
      cartItems.removeWhere((item) => item.artworkId == artworkId);
      Get.snackbar("Removed", "Item removed from cart");
    }
  }
}
