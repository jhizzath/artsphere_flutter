import 'package:artsphere/controller/artist/artistFeedbackController.dart';
import 'package:artsphere/controller/artist/artworkController.dart';
import 'package:artsphere/controller/artist/orderDetailController.dart';
import 'package:artsphere/controller/artist/profileController.dart';
import 'package:artsphere/controller/artist/artistVideoController.dart';
import 'package:artsphere/controller/customer/CustomerProfileController.dart';
import 'package:artsphere/controller/customer/cartController.dart';
import 'package:artsphere/controller/customer/customerVideoController.dart';
import 'package:artsphere/controller/customer/favoriteController.dart';
import 'package:artsphere/controller/customer/orderController.dart';
import 'package:artsphere/controller/feedbackController.dart';
import 'package:artsphere/screens/artistView/artistHome.dart';
import 'package:artsphere/screens/customerView/cust_main.dart';
import 'package:artsphere/screens/customerView/orderSuccesspage.dart';
import 'package:artsphere/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller/categoryController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controllers
  Get.put(CategoryController());
  Get.put(ArtistProfileController());
  Get.put(ArtworkController());
  Get.put(CustomerProfileController());
  

  Get.put(ArtistVideoController());
  Get.put(CustomerVideoController());
  Get.put(FavoriteController());
  Get.put(FeedbackController());
  Get.put(ArtistFeedbackController());


  Get.put(CartController());
  Get.put(OrderController());
  Get.put(ArtistOrderController(), permanent: true);


  // Get shared preferences
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userType = prefs.getString('user_type') ?? '';

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    userType: userType,
    token: token,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userType;
  final String token;
  
  const MyApp({
    required this.isLoggedIn,
    required this.userType,
    required this.token,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: [
    // ... your other routes ...
    GetPage(
      name: '/order-confirmation',
      page: () => OrderConfirmationPage(), // Your confirmation page widget
    ),
  ],
      debugShowCheckedModeBanner: false,
      title: 'Artsphere',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _getHomeScreen(),
    );
  }

  Widget _getHomeScreen() {
    if (token.isNotEmpty && isLoggedIn) {
      return userType.toLowerCase() == 'customer' 
          ? CustomerMain() 
          : ArtistHomePage();
    }
    return LoginScreen();
  }
}

