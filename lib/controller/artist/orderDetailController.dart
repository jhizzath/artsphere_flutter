import 'dart:developer';

import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/orderDetailModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ArtistOrderController extends GetxController {
  var orders = [].obs;
  var orderDetail = Rxn<OrderModel>();
  var isLoading = false.obs;

  final String baseUrl = AppConstants.baseUrl; // replace with your backend URL

  Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  print('Current token🧐🧐🧐🧐🧐: $token'); // Add this for debugging
  return prefs.getString('token')?.trim();
}

  Future<void> fetchOrders() async {
  final token = await _getToken();
  isLoading.value = true;
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/artist/orders/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      orders.value = data.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  } catch (e) {
    Get.snackbar('Error', e.toString());
  } finally {
    isLoading.value = false;
  }
}


  Future<void> fetchOrderDetail(String token, int orderId) async {
  isLoading.value = true;
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/artist/orders/$orderId/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log("order detail 👉👉👉👉 $data");
      orderDetail.value = OrderModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch order details');
    }
  } catch (e) {
    Get.snackbar('Error', e.toString());
  } finally {
    isLoading.value = false;
  }
}


  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final token = await _getToken();
      if (token == null) {
        Get.snackbar('Error', 'Authentication required');
        return;
      }

      isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/artist/orders/$orderId/update-status/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}), // Ensure proper JSON encoding
      );

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success', 
          responseBody['message'] ?? 'Status updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchOrderDetail(token, orderId);
        await fetchOrders();
      } else {
        throw Exception(responseBody['error'] ?? 'Failed to update status');
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
}
  
  
