import 'dart:convert';
import 'dart:io';

import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/controller/categoryController.dart';
import 'package:artsphere/controller/artist/profileController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/artist_profile_model.dart' as artistModel;

class EditProfileController extends GetxController {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final professionController = TextEditingController();

  var selectedCategoryId = ''.obs;
  var selectedSubcategoryIds = <String>[].obs;
  var profileImage = Rx<XFile?>(null);
  var isLoading = false.obs;
  artistModel.ArtistProfile? existingProfile;
  final ImagePicker _picker = ImagePicker();

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        profileImage.value = pickedFile;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: ${e.toString()}");
    }
  }

  String? getProfileImageUrl() {
    if (profileImage.value != null) {
      return profileImage.value!.path;
    }
    if (existingProfile?.profilePicture != null && 
        existingProfile!.profilePicture!.isNotEmpty) {
      String url = existingProfile!.profilePicture!;
      if (!url.startsWith('http')) {
        url = 'http://192.168.145.221:8000${url.startsWith('/') ? '' : '/'}$url';
      }
      return url;
    }
    return null;
  }

  Future<void> updateProfile(BuildContext context) async {
    final token = await _getToken();
    if (token == null) {
      Get.snackbar("Error", "Authentication token not found");
      return;
    }

    isLoading(true);

    try {
      final uri = Uri.parse(
        "${AppConstants.baseUrl}/api/profile/update/${usernameController.text}/");

      final request = http.MultipartRequest('PATCH', uri);
      request.headers['Authorization'] = 'Token $token';

      request.fields.addAll({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'phone_no': phoneController.text.trim(),
        'category': selectedCategoryId.value,
        'name': nameController.text.trim(),
        'profession': professionController.text.trim(),
      });

      if (passwordController.text.trim().isNotEmpty) {
        request.fields['password'] = passwordController.text.trim();
      }

      if (selectedSubcategoryIds.isNotEmpty) {
        request.fields['subcategories'] = jsonEncode(
          selectedSubcategoryIds.map((e) => int.tryParse(e)).whereType<int>().toList(),
        );
      }

      if (profileImage.value != null) {
        final file = File(profileImage.value!.path);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_picture',
              file.path,
            ),
          );
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Profile updated successfully!");
        Navigator.pop(context);
        final profileController = Get.find<ArtistProfileController>();
        await profileController.fetchArtistProfile(usernameController.text);
      } else {
        Get.snackbar("Error", "Failed to update profile");
        debugPrint("Error response: $responseBody");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception occurred: $e");
      debugPrint("Exception: $e");
    } finally {
      isLoading(false);
    }
  }

  void loadFromExistingProfile(artistModel.Post profile) {
    usernameController.text = profile.username;
    emailController.text = profile.email;
    phoneController.text = profile.phoneNo;
    nameController.text = profile.artistProfile?.name ?? '';
    professionController.text = profile.artistProfile?.profession ?? '';
    existingProfile = profile.artistProfile;

    if (profile.artistProfile != null) {
      selectedCategoryId.value = profile.artistProfile!.category.id.toString();
      Get.find<CategoryController>().updateSubcategories(profile.artistProfile!.category.id);
      
      selectedSubcategoryIds.assignAll(
        profile.artistProfile!.subcategories
            .map((subcat) => subcat.id.toString())
            .toList()
      );
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    nameController.dispose();
    professionController.dispose();
    super.onClose();
  }
}