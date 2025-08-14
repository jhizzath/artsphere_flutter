
import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/orderModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderController extends GetxController {
  final String baseUrl = AppConstants.baseUrl; // Your backend URL
  var orders = <Order>[].obs;
  var isLoading = false.obs;

  static var to;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
 

 Future<String?> createOrder({
  required List<Map<String, dynamic>> items,
  required int shippingAddressId,
  required String paymentMethod,
  bool fromCart = false,
}) async {
  isLoading.value = true;
  final token = await _getToken();
  
  if (token == null) {
    Get.snackbar('Error', 'Authentication required');
    isLoading.value = false;
    return null;
  }

  try {
    print("order🧐🧐🧐🧐🧐"+jsonEncode({
        'items': items,
        'shipping_address_id': shippingAddressId,
        'payment_method': paymentMethod,
        'from_cart' : fromCart
      }));
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders/create/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'items': items,
        'shipping_address_id': shippingAddressId,
        'payment_method': paymentMethod,
        'from_cart' : fromCart
      }),
      
    );

    final responseBody = jsonDecode(response.body);
    
    if (response.statusCode == 201) {
      // Get the order ID from response
      final orderId = responseBody['id']?.toString();
      
      // Verify order exists in backend
      final verified = await _verifyOrderCreation(orderId);
      
      if (verified) {
        Get.snackbar(
          'Success', 
          'Order #$orderId placed successfully',
          duration: Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchOrders();
        return orderId;
      } else {
        throw Exception('Order verification failed');
      }
    } else {
      // Extract detailed error from backend
      final error = responseBody['error'] ?? 
                   responseBody['message'] ?? 
                   'Failed to place order (Status: ${response.statusCode})';
      throw Exception(error);
    }
  } catch (e) {
    Get.snackbar(
      'Error', 
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return null;
  } finally {
    isLoading.value = false;
  }
}

Future<bool> _verifyOrderCreation(String? orderId) async {
  if (orderId == null) return false;
  
  try {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/$orderId/'),
      headers: {'Authorization': 'Token $token'},
    );
    
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

  Future<void> fetchOrders() async {
  isLoading.value = true;
  final token = await _getToken();
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      print("orders📦📦📦📦📦$data");
      orders.value = data.map((item) => Order.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch orders: ${response.statusCode}');
    }
  } catch (e) {
    Get.snackbar(
      'Error', 
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}
  // Add to OrderController
Future<void> cancelOrder(String orderId) async {
  try {
    final token = await _getToken();
    if (token == null) {
      Get.snackbar('Error', 'Authentication required');
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/orders/$orderId/cancel/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Get.snackbar(
        'Success', 
        'Order cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await fetchOrders(); // Refresh the list
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Failed to cancel order';
      throw Exception(error);
    }
  } catch (e) {
    Get.snackbar(
      'Error', 
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
Future<bool> confirmDelivery(int orderId) async {
  try {
    final token = await _getToken();
    if (token == null) {
      Get.snackbar('Error', 'Authentication required');
      return false;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/orders/$orderId/confirm-delivery/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Get.snackbar(
        'Success', 
        'Delivery confirmed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await fetchOrders(); // Refresh the orders list
      return true;
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Failed to confirm delivery';
      throw Exception(error);
    }
  } catch (e) {
    Get.snackbar(
      'Error', 
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return false;
  }
}

  Future<bool> markOrderCompleted(int orderId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        Get.snackbar('Error', 'Authentication required');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/artist/orders/$orderId/mark-completed/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success', 
          'Order marked as completed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchOrders();
        return true;
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to mark order as completed';
        throw Exception(error);
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }


}