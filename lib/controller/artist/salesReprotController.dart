import 'dart:convert';

import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/salesReportModel.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SalesReportController extends GetxController {
  final Rx<SalesReport?> salesReport = Rx<SalesReport?>(null);
  final isLoading = false.obs;
  var baseUrl = AppConstants.baseUrl;

   Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('Retrieved token: $token');  // Debug print
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<void> fetchSalesReport({int days = 30}) async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/artist/sales-report/?days=$days'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        salesReport.value = SalesReport.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load sales report');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}