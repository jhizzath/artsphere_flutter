import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/uploadArtworkService.dart';

class UploadArtworkController extends GetxController {
  var isLoading = false.obs;

  final ArtworkService _artworkService = ArtworkService();

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

  Future<void> uploadArtwork({
    
    required String title,
    required String description,
    required double price,
    required List<File> images,
    required List<int> selectedSubcategoryIds,
    required String category,
     required int count,
    
  }) async {
    try {
      final token = await _getToken();
  if (token == null) {
    isLoading(false);
    Get.snackbar("Error", "Authentication token not found");
    return;
  }
      isLoading.value = true;
      await _artworkService.uploadArtwork(
        token: token,
        title: title,
        description: description,
        price: price,
        images: images,
        selectedSubcategoryIds: selectedSubcategoryIds,
        category: category,
        count:count
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload artwork: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
