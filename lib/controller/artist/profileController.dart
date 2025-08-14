// controllers/artist_profile_controller.dart
import 'dart:convert';

import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/artist_profile_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ArtistProfileController extends GetxController {
  var isLoading = true.obs;
  var artistProfile = Rxn<Post>();
  var error = ''.obs;
  var selectedCategoryId = ''.obs;
  var selectedSubcategories = <String>[].obs;

  Future<void> fetchArtistProfile(String username) async {
    try {
      isLoading(true);
      error('');
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/profile/$username/'),
        headers: {'Accept': 'application/json'},
      );

       print('✅ Full API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        artistProfile.value = Post.fromJson(jsonData);
      } else {
        error.value = 'Failed to load profile: ${response.statusCode}';
        Get.snackbar('Error', error.value);
      }
    } catch (e) {
      error.value = 'Error fetching profile: $e';
      Get.snackbar('Error', error.value);
    } finally {
      isLoading(false);
    }
  }
}