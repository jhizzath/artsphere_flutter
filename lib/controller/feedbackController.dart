// controllers/feedback_controller.dart
import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/feedbackModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FeedbackController extends GetxController {
  final String baseUrl = AppConstants.baseUrl;
  var isLoading = false.obs;
  var feedbackList = <FeedbackModel>[].obs;

  Future<bool> submitFeedback({
  required String feedbackType,
  int? artworkId,
  int? rating,
  required String comment,
}) async {
  isLoading.value = true;
  try {
    // Validate required fields before sending
    if (comment.isEmpty) {
      throw Exception('Please enter your feedback');
    }

    if (feedbackType == 'artwork' && artworkId == null) {
      throw Exception('Please select an artwork');
    }

    final Map<String, dynamic> body = {
      'feedback_type': feedbackType,
      'comment': comment,
      if (artworkId != null) 'artwork': artworkId,
      if (rating != null) 'rating': rating,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/feedback/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await _getToken()}',
      },
      body: jsonEncode(body),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 201) {
      print('Submitting feedback with body: ${jsonEncode(body)}');
      Get.snackbar('Success', 'Feedback submitted successfully');
      return true;
    } else if (response.statusCode == 400) {
      // Parse Django validation errors
      final errorMsg = _parseDjangoErrors(responseBody);
      throw Exception(errorMsg);
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  } catch (e) {
    Get.snackbar(
      'Submission Failed', 
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 4),
    );
    return false;
  } finally {
    isLoading.value = false;
  }
}

String _parseDjangoErrors(dynamic responseBody) {
  if (responseBody is Map) {
    return responseBody.entries
        .map((e) => '${e.key}: ${e.value is List ? e.value.join(', ') : e.value}')
        .join('\n');
  }
  return 'Invalid data submitted';
}
 
Future<void> fetchArtworkFeedback(int artworkId) async {
  isLoading.value = true;
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/feedback/artwork/$artworkId/'),
      headers: {
        'Authorization': 'Token ${await _getToken()}',
      },
    );

    if (response.statusCode == 200) {
      print("feedback 🥳🥳🥳${response.body}");
      final List<dynamic> data = jsonDecode(response.body);
      feedbackList.value = data
          .map((json) => FeedbackModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load feedback');
    }
  } catch (e) {
    Get.snackbar('Error', e.toString());
  } finally {
    isLoading.value = false;
  }
}
Future<void> custfetchArtworkFeedback(int artworkId) async {
  isLoading.value = true;
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/artworks/$artworkId/customer-feedback/'),
      headers: {
        'Authorization': 'Token ${await _getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      feedbackList.value = data
          .map((json) => FeedbackModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load feedback');
    }
  } catch (e) {
    Get.snackbar('Error', e.toString());
  } finally {
    isLoading.value = false;
  }
}

  Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  print('Current token🧐🧐🧐🧐🧐: $token'); // Add this for debugging
  return prefs.getString('token')?.trim();
}
}