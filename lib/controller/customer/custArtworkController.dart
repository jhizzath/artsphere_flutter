import 'dart:convert';
import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/artworkModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CustomerArtworkController extends GetxController {
  var isLoading = false.obs;
  var artworkList = <ArtworkModel>[].obs;
  var selectedSubcategoryId = ''.obs;
  final String baseUrl = AppConstants.baseUrl;

 Future<void> fetchCustomerArtworks({
  int? categoryId, 
  List<String>? subcategoryIds,
  String? searchQuery,
}) async {
  try {
    isLoading(true);
    artworkList.clear();

    final uri = Uri.parse('$baseUrl/artworks/customer/').replace(
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (subcategoryIds != null && subcategoryIds.isNotEmpty) 
          'subcategory_ids': subcategoryIds.join(','),
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
      },
    );

    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      print("artwork🥳🥳🥳🥳🥳${response.body}");
      final dynamic responseData = jsonDecode(response.body);
      
      if (responseData is List) {
        
        artworkList.assignAll(
          (responseData.toList()).map((item) => 
            ArtworkModel.fromJson(item as Map<String, dynamic>)
          ).toList()
        );
      } else if (responseData is Map) {
        artworkList.add(
          ArtworkModel.fromJson(responseData as Map<String, dynamic>)
        );
      }
    } else {
      throw "Failed to load artworks: ${response.statusCode}";
    }
  } catch (e) {
    throw "Failed to load artworks: $e";
  } finally {
    isLoading(false);
  }
}
}
