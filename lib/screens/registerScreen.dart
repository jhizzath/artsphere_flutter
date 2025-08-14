import 'dart:convert';

import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/controller/categoryController.dart';
import 'package:artsphere/screens/login_screen.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// import 'package:snippet_coder_utils/FormHelper.dart';
// import 'package:getwidget/getwidget.dart';

class Registerscreen extends StatefulWidget {
  const Registerscreen({super.key});

  @override
  State<Registerscreen> createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<Registerscreen> {
  final _formKey = GlobalKey<FormState>();

  List subcat = [];

  final CategoryController categoryController = Get.put(CategoryController());
  String? catId;
  String? subcatId;
  // ✅ Store selected subcategories
  String? selectedCategory;
  // List<String> selectedSubcategories = [];

  // ✅ Declare Controllers Outside build()
  final TextEditingController usernameController = TextEditingController();
  // final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // ✅ Store Selected User Type
  final userType = "Customer".obs; // Make this reactive
  final selectedSubcategories = <String>[].obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(height: 80),
            Center(
              child: Text(
                "Sign Up",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),

            // ✅ Reusable TextFields
            _buildTextField(usernameController, "Username", "Enter a username"),
            // _buildTextField(addressController, "Address", "Enter your address"),
            _buildTextField(
              phoneController,
              "Phone No",
              "Enter your phone number",
              isPhone: true,
            ),
            _buildTextField(
              emailController,
              "Email",
              "Enter your email address",
              isEmail: true,
            ),
            _buildTextField(
              passwordController,
              "Password",
              "Enter a password",
              isPassword: true,
            ),
            _buildTextField(
              confirmPasswordController,
              "Confirm Password",
              "Re-enter your password",
              isPassword: true,
              isConfirmPassword: true,
            ),
            SizedBox(height: 20),

            // ✅ User Type Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "User Type:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
                CustomRadioButton(
                  elevation: 3,
                  absoluteZeroSpacing: false,
                  unSelectedColor: Theme.of(context).canvasColor,
                  selectedBorderColor: Theme.of(context).hoverColor,
                  unSelectedBorderColor: Theme.of(context).hoverColor,
                  buttonLables: ["Customer", "Artist"],
                  buttonValues: ["Customer", "Artist"],
                  buttonTextStyle: ButtonTextStyle(
                    textStyle: TextStyle(fontSize: 15),
                  ),
                  radioButtonValue: (value) {
                    print(
                      "Radio Button Clicked! Value: $value",
                    ); // ✅ Check if callback is triggered

                    setState(() {
                      userType.value = value.toString();
                      print(
                        "Updated User Type: $userType",
                      ); // ✅ Verify if value is updating
                    });
                  },

                  selectedColor: Theme.of(context).primaryColor,
                ),
              ],
            ),

            SizedBox(height: 30),

            // ✅ Replace Subcategory Dropdown with Checkboxes
            if (userType == "Artist") ...[
              // Category Dropdown
              Obx(() {
                if (categoryController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: "Select Category",
                        border: OutlineInputBorder(),
                      ),
                      value:
                          selectedCategory != null
                              ? int.tryParse(selectedCategory!)
                              : null,
                      items:
                          categoryController.categories.map((category) {
                            return DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategory = newValue.toString();
                          categoryController.updateSubcategories(newValue!);
                          selectedSubcategories.clear();
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Please select a category' : null,
                    ),

                    // ]);
                    //  }),
                    SizedBox(height: 20),

                    // Subcategories Checkboxes
                    // Obx(() {
                    //   if (selectedCategory == null) {
                    //     return Text('Please select a category first',
                    //         style: TextStyle(color: Colors.grey));
                    //   }

                    //   if (categoryController.subcategories.isEmpty) {
                    //     return Text('No subcategories available for selected category',
                    //         style: TextStyle(color: Colors.grey));
                    //   }
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Subcategories:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...categoryController.subcategories.map((subcat) {
                          return CheckboxListTile(
                            title: Text(subcat.name),
                            value: selectedSubcategories.contains(
                              subcat.id.toString(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                final subcatId = subcat.id.toString();
                                if (value == true) {
                                  if (!selectedSubcategories.contains(
                                    subcatId,
                                  )) {
                                    selectedSubcategories.add(subcatId);
                                  }
                                } else {
                                  selectedSubcategories.remove(subcatId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                );
              }),
            ],
            SizedBox(height: 30),

            // ✅ Register Button
            ElevatedButton(
              onPressed: _registerUser,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text("Register", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ✅ Function to Handle Registration
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      // Additional manual validation for category and subcategories
      if (userType == "Artist") {
        if (selectedCategory == null) {
          _showError("Please select a category");
          return;
        }
        if (selectedSubcategories.isEmpty) {
          _showError("Please select at least one subcategory");
          return;
        }
      }

      print("Username: ${usernameController.text}");
      print("Phone: ${phoneController.text}");
      print("Email: ${emailController.text}");
      print("Password: ${passwordController.text}");
      print("User Type: $userType");
      if (userType == "Artist") {
        print("category=====" + selectedCategory.toString());
        print("subcategories=====" + selectedSubcategories.toString());
      }

      // ✅ Prepare data to send to backend
      String apiUrl = "${AppConstants.baseUrl}/api/register/";

      final Map<String, dynamic> userData = {
        "username": usernameController.text,
        "email": emailController.text,
        "phone_no": phoneController.text,
        "password": passwordController.text,
        "user_type":
            userType.toLowerCase() == "customer" ? "customer" : "artist",
      };

      if (userType == "Artist") {
        if (selectedCategory != null) {
          userData["category_id"] = int.parse(selectedCategory!);
        } else {
          _showError("Please select a category.");
          return;
        }

        if (selectedSubcategories.isEmpty) {
          _showError("Please select at least one subcategory.");
          return;
        }

        userData["subcategories"] =
            selectedSubcategories.map((id) => int.parse(id)).toList();
      }

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(userData),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print("✅ Registered successfully");

          if (responseData['requires_approval'] == true) {
            // Show approval pending snackbar for artists
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Your artist account is pending admin approval. "
                  "You'll receive an email when approved.",
                  style: TextStyle(fontSize: 16),
                ),
                duration: Duration(seconds: 5),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          } else {
            // For customers, show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Registration successful! Please login.",
                  style: TextStyle(fontSize: 16),
                ),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.green,
              ),
            );
          }
          // Navigate to login after showing message
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }
          });
        } else {
          print("❌ Failed: ${response.body}");
          _showError("Registration failed. Please try again.");
        }
      } catch (e) {
        print("⚠️ Error: $e");
        _showError("Something went wrong: $e");
      }
    }
  }

  // ✅ Reusable TextField Widget
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isPassword = false,
    bool isEmail = false,
    bool isPhone = false,
    bool isConfirmPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType:
            isPhone
                ? TextInputType.phone
                : isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
        inputFormatters:
            isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label is required";
          }
          if (isEmail &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
            return "Enter a valid email";
          }
          if (isConfirmPassword && value != passwordController.text) {
            return "Passwords do not match";
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
}
