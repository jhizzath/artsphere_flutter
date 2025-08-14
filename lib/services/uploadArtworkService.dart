import 'dart:convert';
import 'dart:io';
import 'package:artsphere/baseUrl.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ArtworkService extends GetxService {

  
  Future<void> uploadArtwork({
     required String token,
    required String title,
    required String description,
    required double price,
    required List<File> images,
    required List<int> selectedSubcategoryIds,
    required String category, 
    required int count,
    
  }) async {
    

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    
    if (username == null) {
      Get.snackbar('Error', 'Username not found');
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}/api/upload-artwork/'));//192.168.43.209

    // Add form fields
    request.headers['Authorization'] = 'Token $token';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['artist'] = username;  // Updated key to match backend
    request.fields['category'] = category;
    request.fields['count'] = count.toString();
    
    // Add images
    for (var image in images) {
      var mimeType = lookupMimeType(image.path);
      var fileExtension = mimeType?.split('/')[1] ?? 'jpg';
      request.files.add(await http.MultipartFile.fromPath(
        'images', image.path,
        contentType: MediaType('image', fileExtension),
      ));
    }

    // Add subcategories
    request.fields['subcategories'] = jsonEncode(selectedSubcategoryIds);

    try {
      // Send the request
      var response = await request.send();

      // Check the response status
      if (response.statusCode == 201) {
  final responseBody = await response.stream.bytesToString();
  final data = json.decode(responseBody);

  // Success because status code is 201
  Get.snackbar('Success', 'Artwork uploaded successfully');
  print('Response data: $data');
} else {
  Get.snackbar('Error', 'Failed to upload artwork. Status code: ${response.statusCode}');
}
    } catch (e) {
      Get.snackbar('Error', 'Network error: $e');
    }
  }
}
