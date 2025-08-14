import 'dart:developer';
import 'dart:io';

import 'package:artsphere/controller/artist/profileController.dart';
import 'package:artsphere/controller/artist/uploadArtworkController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadArtworkPage extends StatefulWidget {
  const UploadArtworkPage({super.key});

  @override
  State<UploadArtworkPage> createState() => _UploadArtworkPageState();
}

class _UploadArtworkPageState extends State<UploadArtworkPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = []; // List to store selected images
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController =
      TextEditingController(); // Price controller

  int count = 1; // Initial count value
  final ArtistProfileController artistProfileController = Get.put(
    ArtistProfileController(),
  );
  final UploadArtworkController uploadArtworkController = Get.put(
    UploadArtworkController(),
  );
  List<int> selectedSubcategoryIds =
      []; // Use a list to store selected subcategory IDs

  @override
  void initState() {
    super.initState();
    _loadUsernameAndFetchProfile();
  }

  void _loadUsernameAndFetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');

    if (username != null) {
      artistProfileController.fetchArtistProfile(username);
    } else {
      print("⚠️ Username not found in SharedPreferences!");
    }
  }

  // Pick multiple images
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(); // Pick multiple images
    // ignore: unnecessary_null_comparison
    if (pickedFiles != null) {
      setState(() {
        _images =
            pickedFiles
                .map((file) => File(file.path))
                .toList(); // Convert to File objects
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload New Artwork"),
        backgroundColor: const Color.fromARGB(255, 210, 227, 236),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Image Thumbnails Grid
                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_images[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _images.removeAt(index); // Remove image
                                });
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 12,
                                child: Icon(Icons.close, size: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  // Button to pick images
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: const Text(
                      "Select Images",
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 210, 227, 236),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Title", titleController),
                  const SizedBox(height: 10),
                  _buildTextField(
                    "Description",
                    descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    "Price",
                    priceController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCountRow(),
                  const Divider(color: Color.fromARGB(255, 152, 145, 145)),
                  _buildCategoryRow(),
                  const Divider(color: Color.fromARGB(255, 152, 145, 145)),
                  _buildSubcategoriesRow(),
                  const Divider(color: Color.fromARGB(255, 152, 145, 145)),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          210,
                          227,
                          236,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // Inside the upload button onPressed:
                      onPressed: () {
                        final title = titleController.text;
                        final description = descriptionController.text;
                        final price =
                            double.tryParse(priceController.text) ?? 0.0;
                        final category =
                            artistProfileController
                                .artistProfile
                                .value
                                ?.artistProfile!
                                .category
                                .name ??
                            '';

                        if (title.isEmpty ||
                            description.isEmpty ||
                            price <= 0 ||
                            _images.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please fill all fields and select at least one image',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        uploadArtworkController
                            .uploadArtwork(
                              title: title,
                              description: description,
                              price: price,
                              images: _images,
                              selectedSubcategoryIds: selectedSubcategoryIds,
                              category: category,
                              count: count,
                            )
                            .then((_) {
                               // Go back to previous screen
                              Get.snackbar(
                                'Success',
                                'Artwork uploaded! It will be visible after admin approval',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                duration: Duration(seconds: 4),
                              );
                              Navigator.pop(context);
                            });
                      },
                      child: const Text(
                        "Upload",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TextField helper widget
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int? maxLines,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black),
        ),
        hintText: "Enter $label",
        hintStyle: const TextStyle(color: Colors.black),
      ),
    );
  }

  // Count Row (Not changed)
  Widget _buildCountRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Count",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 120),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (count > 1) count--;
                  });
                },
                icon: const Icon(
                  Icons.remove,
                  color: const Color.fromARGB(255, 210, 227, 236),
                ),
              ),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    count++;
                  });
                },
                icon: const Icon(
                  Icons.add,
                  color: const Color.fromARGB(255, 210, 227, 236),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Category Row (Not changed)
  Widget _buildCategoryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          "Art Category",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 20),
        Obx(() {
          if (artistProfileController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = artistProfileController.artistProfile.value;
          if (profile == null) {
            return const Center(child: Text("Profile not found"));
          }

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      profile.artistProfile!.category.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    backgroundColor: const Color.fromARGB(255, 210, 227, 236),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // Subcategory Row (Not changed)
  Widget _buildSubcategoriesRow() {
    return Obx(() {
      if (artistProfileController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final subprofile = artistProfileController.artistProfile.value;

      // Check if subprofile is null and handle appropriately
      if (subprofile == null) {
        return const Center(child: Text("Profile not found"));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Subcategories",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children:
                subprofile.artistProfile!.subcategories
                    .map<Widget>(
                      (subcategory) => FilterChip(
                        backgroundColor: const Color.fromARGB(
                          255,
                          210,
                          227,
                          236,
                        ),
                        selectedColor: const Color.fromARGB(255, 194, 223, 239),
                        label: Text(subcategory.name),
                        selected: selectedSubcategoryIds.contains(
                          subcategory.id,
                        ), // Check if selected
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              // Add to the selected list
                              if (!selectedSubcategoryIds.contains(
                                subcategory.id,
                              )) {
                                selectedSubcategoryIds.add(subcategory.id);
                              }
                            } else {
                              // Remove from the selected list
                              selectedSubcategoryIds.remove(subcategory.id);
                            }
                            log("selected======$selectedSubcategoryIds");
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
        ],
      );
    });
  }
}
