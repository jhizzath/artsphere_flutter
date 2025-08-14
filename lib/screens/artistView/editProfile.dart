import 'dart:io';

import 'package:artsphere/controller/artist/editProfileController.dart';
import 'package:artsphere/controller/artist/profileController.dart';
import 'package:artsphere/controller/categoryController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final int? category;

  const EditProfilePage({super.key, this.category});

  @override
  State<EditProfilePage> createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final EditProfileController controller = Get.put(EditProfileController());
  final CategoryController categoryController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    categoryController.fetchCategories();
    final artistProfileController = Get.find<ArtistProfileController>();

    if (artistProfileController.artistProfile.value != null) {
      controller.loadFromExistingProfile(
        artistProfileController.artistProfile.value!,
      );
    }

    if (widget.category != null) {
      controller.selectedCategoryId.value = widget.category.toString();
      categoryController.updateSubcategories(widget.category!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Edit Profile")),
        backgroundColor:  Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: Obx(() {
          return controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildProfileImage(),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller.usernameController,
                          "Username",
                          "Enter your username",
                        ),
                        _buildTextField(
                          controller.emailController,
                          "Email",
                          "Enter your email",
                          isEmail: true,
                        ),
                        _buildTextField(
                          controller.phoneController,
                          "Phone",
                          "Enter your phone number",
                          isPhone: true,
                        ),
                        _buildTextField(
                          passwordController,
                          "Password",
                          "Enter password",
                          isPassword: true,
                        ),
                        _buildTextField(
                          controller.nameController,
                          "Name",
                          "Enter your full name",
                        ),
                        _buildTextField(
                          controller.professionController,
                          "Profession",
                          "Enter your profession",
                        ),
                        const SizedBox(height: 20),
                        _buildCategoryDropdown(),
                        const SizedBox(height: 10),
                        _buildSubcategoriesChips(),
                        const SizedBox(height: 30),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                );
        }),
      ),
    );
  }

 Widget _buildProfileImage() {
  return Stack(
    children: <Widget>[
      Obx(() {
        final imageUrl = controller.getProfileImageUrl();
        return CircleAvatar(
          radius: 80,
          backgroundColor: Colors.grey[200],
          backgroundImage: _getImageProvider(imageUrl),
          onBackgroundImageError: (e, stack) {
            debugPrint("Image load error: $e");
          },
          child: controller.profileImage.value == null && 
                 (imageUrl == null || imageUrl.isEmpty)
              ? const Text("data")
              : null,
        );
      }),
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
  );
}

  ImageProvider? _getImageProvider(String? imageUrl) {
  if (controller.profileImage.value != null) {
    return FileImage(File(controller.profileImage.value!.path));
  } else if (imageUrl != null && imageUrl.isNotEmpty) {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    }
  }
  // Use our default avatar
  return const AssetImage('assets/images/default_avatar.png');
}

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose profile photo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text("Gallery"),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Camera"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
  try {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      final compressedFile = await _compressImage(File(pickedFile.path));
      controller.profileImage.value = compressedFile as XFile?;
    }
  } on PlatformException catch (e) {
    Get.snackbar("Error", "Camera permission denied: ${e.message}");
  } catch (e) {
    Get.snackbar("Error", "Failed to capture image: ${e.toString()}");
  }
}

Future<File> _compressImage(File imageFile) async {
  // Implement image compression here or use a package like flutter_image_compress
  return imageFile; // Return as-is for now
}

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Select Category",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      value: controller.selectedCategoryId.value.isEmpty
          ? null
          : controller.selectedCategoryId.value,
      onChanged: (value) {
        if (value != null) {
          controller.selectedCategoryId.value = value;
          categoryController.updateSubcategories(int.parse(value));
          controller.selectedSubcategoryIds.clear();
        }
      },
      items: categoryController.categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id.toString(),
          child: Text(category.name),
        );
      }).toList(),
    );
  }

  Widget _buildSubcategoriesChips() {
    return Obx(() {
      return Wrap(
        spacing: 10,
        children: categoryController.subcategories.map((subcat) {
          final subId = subcat.id.toString();
          final isSelected = controller.selectedSubcategoryIds.contains(subId);
          return FilterChip(
            label: Text(subcat.name),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                controller.selectedSubcategoryIds.add(subId);
              } else {
                controller.selectedSubcategoryIds.remove(subId);
              }
            },
          );
        }).toList(),
      );
    });
  }

  Widget _buildTextField(
    TextEditingController textController,
    String label,
    String hint, {
    bool isPassword = false,
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: textController,
        obscureText: isPassword,
        keyboardType: isPhone
            ? TextInputType.phone
            : isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
        inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
        validator: (value) {
          if (value == null || value.isEmpty) {
            if (isPassword) return null;
            return "$label is required";
          }
          if (isEmail && !value.contains('@')) {
            return "Enter a valid email";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            controller.updateProfile(context);
          }
        },
        child: const Text("Save Changes", style: TextStyle(fontSize: 16,color: Colors.blueGrey,)),
      ),
    );
  }
}