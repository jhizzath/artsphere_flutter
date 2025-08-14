import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   
  
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text('Order Placed Successfully!', style: TextStyle(fontSize: 24)),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.offAllNamed('/'), // Navigate to home
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}