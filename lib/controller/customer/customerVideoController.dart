import 'dart:convert';
import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/videoModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerVideoController extends GetxController {
  var allVideos = <ArtistVideo>[].obs;
  var isLoading = false.obs;
  final String baseUrl = AppConstants.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchAllVideos() async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/videos/all/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          allVideos.value = (data['data'] as List)
              .map((item) => ArtistVideo.fromJson(item))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> likeVideo(int videoId) async {
    final token = await _getToken();
    if (token == null) {
      Get.snackbar('Error', 'You need to login to like videos');
      return;
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/videos/$videoId/like/'),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        // Update the specific video's like status instead of refreshing all
        final index = allVideos.indexWhere((video) => video.id == videoId);
        if (index != -1) {
          final video = allVideos[index];
          final newLikeStatus = !video.isLiked;
          final newLikesCount = newLikeStatus ? video.likesCount + 1 : video.likesCount - 1;
          
          allVideos[index] = ArtistVideo(
            id: video.id,
            title: video.title,
            description: video.description,
            thumbnail: video.thumbnail,
            videoFile: video.videoFile,
            likesCount: newLikesCount,
            views: video.views,
            isLiked: newLikeStatus,
            artistName: video.artistName,
            artistProfilePic: video.artistProfilePic,
          );
        }
      } else {
        Get.snackbar('Error', 'Failed to like video');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> viewVideo(int videoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/videos/$videoId/view/'),
      );

      if (response.statusCode == 200) {
        // Update the view count locally
        final index = allVideos.indexWhere((video) => video.id == videoId);
        if (index != -1) {
          final video = allVideos[index];
          allVideos[index] = ArtistVideo(
            id: video.id,
            title: video.title,
            description: video.description,
            thumbnail: video.thumbnail,
            videoFile: video.videoFile,
            likesCount: video.likesCount,
            views: video.views + 1,
            isLiked: video.isLiked,
            artistName: video.artistName,
            artistProfilePic: video.artistProfilePic,
          );
        }
      }
    } catch (e) {
      print('View count error: $e');
    }
  }
}