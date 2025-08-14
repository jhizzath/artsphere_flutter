import 'dart:convert';
import 'dart:io';
import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/videoModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArtistVideoController extends GetxController {
  var artistVideos = <ArtistVideo>[].obs;
  var isLoading = false.obs;
  final String baseUrl = AppConstants.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchMyVideos() async {
    isLoading.value = true;
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos/artist/'),
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 200) {
        print("artist video😀😀😀😀${response.body}");
        artistVideos.value = (jsonDecode(response.body) as List)
            .map((item) => ArtistVideo.fromJson(item))
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to load your videos');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadVideo({
    required String title,
    required String description,
    required XFile thumbnail,
    required File videoFile,
  }) async {
    isLoading.value = true;
    final token = await _getToken();
    if (token == null) {
      Get.snackbar('Error', 'Authentication token missing');
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/videos/upload/')
      );
      request.headers.addAll({
        'Authorization': 'Token $token',
        'Accept': 'application/json',
      });
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.files.add(await http.MultipartFile.fromPath(
        'thumbnail', thumbnail.path, contentType: MediaType('image', 'jpeg'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'video_file', videoFile.path, contentType: MediaType('video', 'mp4'),
      ));

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        Get.snackbar('Success', 'Video uploaded');
        await fetchMyVideos();
      } else {
        Get.snackbar('Error', 'Upload failed: $responseBody');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }


 Future<void> incrementView(int videoId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final headers = {
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/videos/$videoId/view/'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      print('View increment failed: ${response.body}');
    }
  } catch (e) {
    print('Error incrementing view: $e');
  }
}

}

