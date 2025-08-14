// controllers/artist_feedback_controller.dart
import 'package:artsphere/baseUrl.dart';
import 'package:get/get.dart';
import 'package:artsphere/model/feedbackModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ArtistFeedbackController extends GetxController {
  var isLoading = false.obs;
  var feedbackList = <FeedbackModel>[].obs;
  final String baseUrl = '${AppConstants.baseUrl}';
  var filterType = 'all'.obs;
  var sortBy = 'newest'.obs;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token')?.trim();
  }

  Future<void> fetchArtistFeedback() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/artist-feedback/'),
        headers: {
          'Authorization': 'Token ${await _getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        feedbackList.value = data
            .map((json) => FeedbackModel.fromJson(json))
            .toList();
        _sortFeedback();
      } else {
        throw Exception('Failed to load feedback: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reportFeedback(int feedbackId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/report-feedback/$feedbackId/'),
        headers: {
          'Authorization': 'Token ${await _getToken()}',
        },
      );

      if (response.statusCode == 200) {
        feedbackList.removeWhere((item) => item.id == feedbackId);
        Get.snackbar('Success', 'Feedback reported successfully');
      } else {
        throw Exception('Failed to report feedback: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void applyFilters(String type, String sort) {
    filterType.value = type;
    sortBy.value = sort;
    _sortFeedback();
  }

  void _sortFeedback() {
    var sorted = List<FeedbackModel>.from(feedbackList);
    
    switch (sortBy.value) {
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'lowest':
        sorted.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
        break;
    }
    
    if (filterType.value != 'all') {
      sorted = sorted.where((f) => f.feedbackType == filterType.value).toList();
    }
    
    feedbackList.value = sorted;
  }
}