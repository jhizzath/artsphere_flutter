import 'dart:io';

import 'package:artsphere/screens/customerView/custProfileEdit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artsphere/model/custPorfileModel.dart';
import 'package:artsphere/utils/session_manager.dart';
import 'package:artsphere/controller/customer/CustomerProfileController.dart';

class CustomerProfileScreen extends StatefulWidget {
  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final controller = Get.put(CustomerProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.feedback),
            onPressed: _showFeedbackDialog,
            tooltip: 'Send Feedback',
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Get.to(() => ProfileEditScreen()),
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => SessionManager.logoutUser(context),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
            ),
          );
        }

        final profile = controller.profile.value;
        if (profile == null) {
          return Center(
            child: Text(
              'No profile data',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfilePicture(profile),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: _buildProfileInfo(profile),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfilePicture(CustomerProfile profile) {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 3),
            ),
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  controller.selectedImage.value != null
                      ? FileImage(File(controller.selectedImage.value!.path))
                      : (profile.profilePicture != null &&
                                  profile.profilePicture!.isNotEmpty
                              ? NetworkImage(
                                'http://YOUR_BACKEND_IP:8000/${profile.profilePicture!}',
                              )
                              : AssetImage('assets/images/avatar.png'))
                          as ImageProvider,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                onPressed: _showImagePickerDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(CustomerProfile profile) {
    final address = profile.addresses.isNotEmpty ? profile.addresses[0] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.person_outline, 'Username', profile.username),
        _buildInfoRow(Icons.email_outlined, 'Email', profile.email),
        if (profile.phoneNo != null)
          _buildInfoRow(Icons.phone_outlined, 'Phone', profile.phoneNo!),

        if (address != null) ...[
          Divider(height: 30, color: Colors.grey[300]),
          Text(
            'Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          _buildInfoRow(Icons.home_outlined, 'House', address.houseAddress),
          _buildInfoRow(Icons.location_city_outlined, 'City', address.city),
          _buildInfoRow(Icons.map_outlined, 'District', address.district),
          _buildInfoRow(Icons.flag_outlined, 'State', address.state),
          _buildInfoRow(
            Icons.local_post_office_outlined,
            'Postal Code',
            address.postalCode,
          ),

          Divider(height: 30, color: Colors.grey[300]),
          TextButton(
            onPressed: _showFeedbackDialog,
            child: Text(
              "Send Feedback",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
          ),

          Divider(height: 30, color: Colors.grey[300]),
          TextButton(
            onPressed: () => SessionManager.logoutUser(context),
            child: Text(
              "Logout",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.blueGrey),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImagePickerDialog() {
    Get.defaultDialog(
      title: "Update Profile Picture",
      titleStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      content: Column(
        children: [
          _buildDialogOption(Icons.camera_alt, "Take Photo", () {
            Get.back();
            controller.pickImageFromCamera();
          }),
          SizedBox(height: 12),
          _buildDialogOption(Icons.photo_library, "Choose from Gallery", () {
            Get.back();
            controller.pickImageFromGallery();
          }),
        ],
      ),
      backgroundColor: Colors.white,
      radius: 12,
    );
  }

  Widget _buildDialogOption(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(text, style: TextStyle(color: Colors.black87)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: Colors.grey[50],
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();

    Get.defaultDialog(
      title: "Send Feedback",
      titleStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      content: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      value!.isEmpty ? 'Please enter your feedback' : null,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (feedbackController.text.isNotEmpty) {
                      // Call your feedback submission method
                      // feedbackController.submitFeedback(feedbackController.text);
                      Get.back();
                      Get.snackbar(
                        'Thank You!',
                        'Your feedback has been submitted',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      radius: 12,
    );
  }
}
