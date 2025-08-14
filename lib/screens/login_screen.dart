import 'dart:convert';
import 'dart:developer';
import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/screens/customerView/cust_main.dart';
import 'package:artsphere/screens/registerScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artsphere/screens/artistView/artistHome.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController pswController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    pswController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/App Name
                const Column(
                  children: [
                    Icon(Icons.palette, size: 60, color: Colors.deepPurple),
                    SizedBox(height: 16),
                    Text(
                      "ArtSphere",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Where artists meet art lovers",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Login Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Username Field
                          TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: "Username",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your username";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: pswController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              }
                              if (value.length < 4) {
                                return "Password must be at least 4 characters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Forgot Password
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: TextButton(
                          //     onPressed: () {
                          //       log("pressing forget password");
                          //     },
                          //     style: TextButton.styleFrom(
                          //       padding: EdgeInsets.zero,
                          //     ),
                          //     // child: const Text(
                          //     //   "Forgot Password?",
                          //     //   style: TextStyle(color: Colors.deepPurple),
                          //     // ),
                          //   ),
                          // ),
                          const SizedBox(height: 16),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() => _isLoading = true);
                                          try {
                                            final response = await http.post(
                                              Uri.parse(
                                                "${AppConstants.baseUrl}/api/login/",
                                              ),
                                              headers: {
                                                "Content-Type":
                                                    "application/json",
                                                "Accept": "application/json",
                                              },
                                              body: jsonEncode({
                                                "username":
                                                    usernameController.text
                                                        .trim(),
                                                "password":
                                                    pswController.text.trim(),
                                              }),
                                            );

                                            debugPrint(
                                              'Status Code: ${response.statusCode}',
                                            );
                                            debugPrint(
                                              'Response Body: ${response.body}',
                                            );

                                            if (response.statusCode == 200) {
                                              final responseData = jsonDecode(
                                                response.body,
                                              );
                                              final token =
                                                  responseData['token']
                                                      as String;
                                              final userType =
                                                  responseData['user_type']
                                                      as String;
                                              final username =
                                                  responseData['username']
                                                      as String;

                                              final prefs =
                                                  await SharedPreferences.getInstance();
                                              await prefs.setBool(
                                                'isLoggedIn',
                                                true,
                                              );
                                              await prefs.setString(
                                                'username',
                                                username,
                                              );
                                              await prefs.setString(
                                                'user_type',
                                                userType,
                                              );
                                              await prefs.setString(
                                                'token',
                                                token,
                                              );

                                              if (!mounted) return;
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          userType.toLowerCase() ==
                                                                  'customer'
                                                              ? CustomerMain()
                                                              : const ArtistHomePage(),
                                                ),
                                              );
                                            } else if (response.statusCode ==
                                                403) {
                                              final error =
                                                  jsonDecode(
                                                    response.body,
                                                  )['error'] ??
                                                  'Login failed';
                                              if (error.toString().contains(
                                                'pending approval',
                                              )) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Your artist account is pending approval. Please wait or contact support.",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    duration: Duration(
                                                      seconds: 5,
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                    behavior:
                                                        SnackBarBehavior
                                                            .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    action: SnackBarAction(
                                                      label: 'OK',
                                                      textColor: Colors.white,
                                                      onPressed: () {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).hideCurrentSnackBar();
                                                      },
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      error.toString(),
                                                    ),
                                                    duration: Duration(
                                                      seconds: 3,
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            } else {
                                              final error =
                                                  jsonDecode(
                                                    response.body,
                                                  )['error'] ??
                                                  'Login failed';
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    error.toString(),
                                                  ),
                                                  duration: Duration(
                                                    seconds: 3,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            debugPrint('Login error: $e');
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Login failed: ${e.toString()}",
                                                ),
                                              ),
                                            );
                                          } finally {
                                            if (mounted) {
                                              setState(
                                                () => _isLoading = false,
                                              );
                                            }
                                          }
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        log("clicked sign up");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Registerscreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
