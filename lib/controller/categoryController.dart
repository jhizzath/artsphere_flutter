import 'package:artsphere/baseUrl.dart';
import 'package:artsphere/model/categoryModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CategoryController extends GetxController {
  var categories = <Post>[].obs;
  var subcategories = <Subcategory>[].obs;
  var isLoading = true.obs;
  var error = ''.obs;
  var selectedCategory = Rx<int?>(null);

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading(true);
      error('');
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/categories/'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = postFromJson(response.body);
        categories.assignAll(data);
        print('Successfully loaded ${categories.length} categories');
      } else {
        error('Failed to load categories: ${response.statusCode}');
        print('Error response: ${response.body}');
      }
    } catch (e) {
      error('Error fetching categories: $e');
      print('Exception: $e');
    } finally {
      isLoading(false);
    }
  }

  void updateSubcategories(int categoryId) {
    selectedCategory.value = categoryId; 
    try {
      final category = categories.firstWhere(
        (cat) => cat.id == categoryId,
      );
      subcategories.assignAll(category.subcategories);
    } catch (e) {
      subcategories.clear();
      print('Error updating subcategories: $e');
    }
  }
}