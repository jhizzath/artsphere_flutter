import 'package:artsphere/controller/customer/favoriteController.dart';
import 'package:artsphere/model/favoriteModel.dart';
import 'package:artsphere/screens/customerView/custArtworkDetails.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesPage extends StatelessWidget {
  final FavoriteController favoriteController = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites', 
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => favoriteController.favorites(),
          ),
        ],
      ),
      body: Obx(() {
        if (favoriteController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (favoriteController.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 60, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the heart icon on artworks to add them here',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: favoriteController.favorites.length,
          itemBuilder: (context, index) {
            final favorite = favoriteController.favorites[index];
            return _buildFavoriteItem(favorite, index);
          },
        );
      }),
    );
  }

  Widget _buildFavoriteItem(Favorite favorite, int index) {
    final artwork = favorite.artwork;
    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Get.to(() => ArtworkDetailsPage(artwork: artwork)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: artwork.images.isNotEmpty 
                          ? artwork.images.first.image 
                          : 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artwork.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '₹${artwork.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _removeFavorite(favorite, index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _removeFavorite(Favorite favorite, int index) async {
    final result = await Get.defaultDialog(
      title: "Remove Favorite",
      content: Text("Remove this artwork from your favorites?"),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text("Remove", style: TextStyle(color: Colors.red)),
        ),
      ],
    );

    if (result == true) {
      final success = await favoriteController.removeFavorite(favorite.artwork.id);
      if (!success) {
        Get.snackbar(
          "Error",
          "Failed to remove favorite",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}