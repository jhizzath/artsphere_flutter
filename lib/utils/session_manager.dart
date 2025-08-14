import 'package:artsphere/controller/customer/CustomerProfileController.dart';
import 'package:artsphere/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// utils/session_manager.dart

class SessionManager {
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }

static Future<void> logoutUser(BuildContext context) async {
  try {
    // 1. Clear the token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');  // Specifically remove only the token
    
    // 2. Reset any GetX controllers that store user data
    _resetUserState();
    
    // 3. Clear any ongoing API requests (optional)
    // client.close() if you're using http.Client()
    
    // 4. Navigate to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
    
    // 5. Show logout confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logout failed: ${e.toString()}')),
    );
  }
}

static void _resetUserState() {
  try {
    // Reset CustomerProfileController
    if (Get.isRegistered<CustomerProfileController>()) {
      final controller = Get.find<CustomerProfileController>();
      controller.profile.value = null;
      controller.selectedImage.value = null;
      controller.isLoading.value = false;
      // Clear text controllers if needed
      controller.usernameController.clear();
      controller.emailController.clear();
      controller.phoneController.clear();
    }
    
    // Reset any other user-related controllers
    // Example: CartController.instance.clearCart();
  } catch (e) {
    debugPrint('Error resetting state: $e');
  }
}
}