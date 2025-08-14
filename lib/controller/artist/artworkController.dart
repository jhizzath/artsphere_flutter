import 'dart:convert';
import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/artworkModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ArtworkController extends GetxController {
  var isLoading = true.obs;
  var artworksList = <ArtworkModel>[].obs;
  var showAllArtworks = false.obs; // Toggle for showing all/pending artworks
  
  @override
  void onInit() {
    fetchArtistArtworks();
    super.onInit();
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<void> fetchArtistArtworks() async {
    try {
      isLoading(true);
      final token = await _getToken();
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      
      if (username == null) throw Exception("User not logged in");

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/artworks/artist/$username/?show_all=${showAllArtworks.value}'),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        artworksList.assignAll(
          responseData.map((json) => ArtworkModel.fromJson(json)).toList(),
        );
      } else {
        throw Exception("Failed to load artworks: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load artworks: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  void toggleShowAll() {
    showAllArtworks.toggle();
    fetchArtistArtworks();
  }
}
