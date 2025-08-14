import 'dart:async';

import 'package:artsphere/controller/categoryController.dart';
import 'package:artsphere/controller/customer/cartController.dart';
import 'package:artsphere/controller/customer/custArtworkController.dart';
import 'package:artsphere/controller/customer/favoriteController.dart';
import 'package:artsphere/model/artworkModel.dart';
import 'package:artsphere/screens/customerView/custArtworkDetails.dart';
import 'package:artsphere/screens/customerView/custCartScreen.dart';
import 'package:artsphere/screens/customerView/favoriteScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final CategoryController categoryController = Get.put(CategoryController());
  final CustomerArtworkController artworkController = Get.put(
    CustomerArtworkController(),
  );
  final CartController cartController = Get.put(CartController());
  final FavoriteController favoriteController = Get.put(FavoriteController());

  int? selectedCategoryId;
  List<String> selectedSubcategories = [];
  String searchQuery = "";
  bool initialLoadComplete = false;
  final String baseUrl = 'http://192.168.145.221:8000';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      await categoryController.fetchCategories();
      if (categoryController.categories.isEmpty) throw "No categories found";

      selectedCategoryId = categoryController.categories[0].id;
      categoryController.updateSubcategories(selectedCategoryId!);

      if (categoryController.subcategories.isEmpty) {
        throw "No subcategories found for selected category";
      }

      selectedSubcategories = [
        categoryController.subcategories[0].id.toString(),
      ];
      await _fetchArtworks();

      setState(() {
        initialLoadComplete = true;
      });
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> _handleCategoryChange(int categoryId) async {
    setState(() {
      selectedCategoryId = categoryId;
      selectedSubcategories = [];
    });

    categoryController.updateSubcategories(categoryId);

    if (categoryController.subcategories.isNotEmpty) {
      setState(() {
        selectedSubcategories = [
          categoryController.subcategories[0].id.toString(),
        ];
      });
      await _fetchArtworks();
    }
  }

  Future<void> _handleSubcategoryChange(String subcategoryId) async {
    setState(() {
      selectedSubcategories = [subcategoryId];
    });
    await _fetchArtworks();
  }

  Future<void> _fetchArtworks() async {
    try {
      await artworkController.fetchCustomerArtworks(
        categoryId: selectedCategoryId,
        subcategoryIds: selectedSubcategories,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to load artworks: ${e.toString()}");
    }
  }

  String _buildImageUrl(String path) {
    if (path.isEmpty) return 'https://via.placeholder.com/150';
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$cleanPath';
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (searchQuery != value) {
        setState(() {
          searchQuery = value;
        });
      }
    });
  }

  void _onSearchSubmitted(String value) {
    _searchDebounce?.cancel();
    setState(() {
      searchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = "";
    });
  }

  List<ArtworkModel> get _filteredArtworks {
    if (searchQuery.isEmpty) {
      return artworkController.artworkList;
    }

    final query = searchQuery.toLowerCase();
    return artworkController.artworkList.where((artwork) {
      final matchesName = artwork.title.toLowerCase().contains(query);
      final matchesArtist = artwork.artist.toLowerCase().contains(query);
      return matchesName || matchesArtist;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Artsphere Home"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () => Get.to(() => FavoritesPage()),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () => Get.to(() => CartPage()),
          ),
        ],
      ),
      body:
          !initialLoadComplete
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: _onSearchSubmitted,
                      decoration: InputDecoration(
                        labelText: "Search Artworks or Artists",
                        prefixIcon: Icon(Icons.search),
                        suffixIcon:
                            searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: _clearSearch,
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Categories
                    Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Obx(
                      () => SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              categoryController.categories.map((category) {
                                final catId = category.id;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(category.name),
                                    selected: selectedCategoryId == catId,
                                    onSelected: (selected) {
                                      if (selected)
                                        _handleCategoryChange(catId);
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Subcategories
                    Text(
                      "Subcategories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Obx(
                      () => SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              categoryController.subcategories.map((subcat) {
                                final subId = subcat.id.toString();
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(subcat.name),
                                    selected: selectedSubcategories.contains(
                                      subId,
                                    ),
                                    onSelected:
                                        (selected) =>
                                            _handleSubcategoryChange(subId),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    Text(
                      "Artworks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    Obx(() {
                      if (artworkController.isLoading.value) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return _buildArtworkGrid();
                    }),
                  ],
                ),
              ),
    );
  }

  Widget _buildArtworkGrid() {
    final artworksToDisplay = _filteredArtworks;

    if (artworksToDisplay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No artworks found",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (searchQuery.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                "Try different search terms",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: artworksToDisplay.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        final artwork = artworksToDisplay[index];
        final imageUrl = _buildImageUrl(
          artwork.images.isNotEmpty ? artwork.images.first.image : '',
        );

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              final artworkModel = ArtworkModel(
                id: artwork.id,
                title: artwork.title,
                description: artwork.description,
                price: artwork.price,
                count: artwork.count,
                artist: artwork.artist,
                category: artwork.category,
                subcategories: artwork.subcategories,
                images: artwork.images,
                isApproved:
                    artwork.isApproved ??
                    false, // Add this with appropriate default
                isFeatured:
                    artwork.isFeatured ??
                    false, // Add this with appropriate default
                approvalStatus: artwork.approvalStatus ?? 'pending',
              );
              Get.to(() => ArtworkDetailsPage(artwork: artworkModel));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, progress) => Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  artwork.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '\₹${artwork.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // ignore: unnecessary_null_comparison
                          if (artwork.artist != null) ...[
                            SizedBox(height: 4),
                            Text(
                              'by ${artwork.artist}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(
                                () => IconButton(
                                  icon: Icon(
                                    favoriteController.isFavorite(artwork.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 18,
                                    color:
                                        favoriteController.isFavorite(
                                              artwork.id,
                                            )
                                            ? Colors.red
                                            : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    final success = await favoriteController
                                        .toggleFavorite(artwork.id);
                                    // ignore: unnecessary_null_comparison
                                    if (success != null) {
                                      Get.snackbar(
                                        success
                                            ? 'Added to Favorites'
                                            : 'Removed from Favorites',
                                        artwork.title,
                                        snackPosition: SnackPosition.BOTTOM,
                                        duration: Duration(seconds: 1),
                                      );
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  cartController.addToCart(artwork.id);
                                },
                                child: Text(
                                  'Add to Cart',
                                  style: TextStyle(fontSize: 11),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
