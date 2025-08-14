
import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/custPorfileModel.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerProfileController extends GetxController {
  var profile = Rxn<CustomerProfile>();
  var isLoading = true.obs;
  var selectedImage = Rx<XFile?>(null);

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    fetchProfile();
    super.onInit();
  }

  // In your Flutter controller, update the _getToken() method:
Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  print('Current token🧐🧐🧐🧐🧐: $token'); // Add this for debugging
  return prefs.getString('token')?.trim();
}

  Future<void> fetchProfile() async {
  isLoading.value = true;
  final token = await _getToken();

  try {
    if (token == null ) {
        throw Exception('Authentication data not found');
      }
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/customer/profile/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      profile.value = CustomerProfile.fromJson(data); // Now this will work
    }
  } finally {
    isLoading.value = false;
  }
}
 Future<void> pickImageFromGallery() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    selectedImage.value = pickedFile;
    await uploadProfilePicture(pickedFile); // Pass the image here
  }
}

Future<void> pickImageFromCamera() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
  if (pickedFile != null) {
    selectedImage.value = pickedFile;
    await uploadProfilePicture(pickedFile); // Pass the image here
  }
}

Future<void> updateProfile(CustomerProfile updated) async {
  final token = await _getToken();
  if (token == null) {
    print('No token available');
    return;
  }

  final url = '${AppConstants.baseUrl}/customer/profile/update/';
  final payload = updated.toUpdateJson();
  
  print('Sending to $url');
  print('Full payload: $payload');
  print('Headers: ${{
    'Authorization': 'Token $token',
    'Content-Type': 'application/json'
  }}');

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      await fetchProfile();
      Get.snackbar('Success', 'Profile updated successfully');
    } else {
      final error = json.decode(response.body);
      Get.snackbar('Error', error.toString());
    }
  } catch (e) {
    print('Network error: $e');
    Get.snackbar('Error', 'Network error: ${e.toString()}');
  }
}

Future<void> uploadProfilePicture(XFile image) async {
  final token = await _getToken();
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}/customer/profile/picture/'),
    );
    request.headers['Authorization'] = 'Token $token';
    request.files.add(await http.MultipartFile.fromPath(
      'profile_picture',
      image.path,
    ));

    var response = await request.send();
    if (response.statusCode == 200) {
      await fetchProfile();
      Get.snackbar('Success', 'Profile picture updated');
    } else {
      Get.snackbar('Error', 'Failed to upload picture');
    }
  } catch (e) {
    Get.snackbar('Error', 'Upload error: $e');
  }
}
}
