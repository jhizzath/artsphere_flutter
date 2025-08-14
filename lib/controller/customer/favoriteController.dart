import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/favoriteModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteController extends GetxController {
  final String baseUrl = AppConstants.baseUrl;
  var favorites = <Favorite>[].obs;
  var isLoading = false.obs;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token')?.trim();
  }

  Future<void> fetchFavorites() async {
    try {
      isLoading(true);
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/'),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        favorites.value = data.map((json) => Favorite.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch favorites');
    } finally {
      isLoading(false);
    }
  }

  // Add this new method
  Future<bool> removeFavorite(int artworkId) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/favorites/remove/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'artwork_id': artworkId}),
      );

      if (response.statusCode == 200) {
        // Remove from local list immediately
        favorites.removeWhere((fav) => fav.artwork.id == artworkId);
        Get.snackbar(
          'Success', 
          'Removed from favorites',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove favorite');
      return false;
    }
  }

  Future<bool> toggleFavorite(int artworkId) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/favorites/toggle/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'artwork_id': artworkId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        fetchFavorites(); // Refresh the list
        return data['status'] == 'added';
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorite');
      return false;
    }
  }

  bool isFavorite(int artworkId) {
    return favorites.any((fav) => fav.artwork.id == artworkId);
  }
}