import 'package:artsphere/controller/customer/cartController.dart';
import 'package:artsphere/controller/customer/favoriteController.dart';
import 'package:artsphere/controller/feedbackController.dart';
import 'package:artsphere/model/feedbackModel.dart';
import 'package:artsphere/screens/customerView/CheckoutPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:artsphere/model/artworkModel.dart';
import 'package:get/get.dart';

class ArtworkDetailsPage extends StatefulWidget {
  final ArtworkModel artwork;

  const ArtworkDetailsPage({Key? key, required this.artwork}) : super(key: key);

  @override
  State<ArtworkDetailsPage> createState() => _ArtworkDetailsPageState();
}

class _ArtworkDetailsPageState extends State<ArtworkDetailsPage> {
  int quantity = 1;
  final String baseUrl = 'http://192.168.145.221:8000';
  final RxBool isFavorited = false.obs;
  int _currentImageIndex = 0;
  final CartController cartController = Get.find<CartController>();
  final FavoriteController favoriteController = Get.find<FavoriteController>();
  final FeedbackController feedbackController = Get.put(FeedbackController());
  final TextEditingController feedbackTextController = TextEditingController();
  int? selectedRating;
  bool showFeedbackForm = false;

  @override
  void initState() {
    super.initState();
    feedbackController.custfetchArtworkFeedback(widget.artwork.id);
  }

  String _buildImageUrl(String path) {
    if (path.isEmpty) return 'https://via.placeholder.com/150';
    if (path.startsWith('http')) return path;
    return '$baseUrl${path.startsWith('/') ? path : '/$path'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Artwork Details"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            _buildArtworkDetails(),
            _buildFeedbackSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Customer Reviews",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => setState(() => showFeedbackForm = !showFeedbackForm),
              child: Text(showFeedbackForm ? 'Hide Form' : 'Leave Feedback'),
            ),
          ],
        ),
        if (showFeedbackForm) _buildFeedbackForm(),
        const SizedBox(height: 8),
        Obx(() {
          if (feedbackController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // No need to filter here since the endpoint should return only relevant feedback
          if (feedbackController.feedbackList.isEmpty) {
            return Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.reviews, size: 40, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  "No reviews yet",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  "Be the first to share your thoughts!",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          }
          
          return Column(
            children: feedbackController.feedbackList
                .map((feedback) => _buildFeedbackCard(feedback))
                .toList(),
          );
        }),
      ],
    ),
  );
}
  Widget _buildFeedbackForm() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Share Your Thoughts",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              "Rating",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedRating = index + 1),
                  child: Icon(
                    selectedRating != null && index < selectedRating!
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackTextController,
              decoration: InputDecoration(
                labelText: 'Your review',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 14),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() {
                    showFeedbackForm = false;
                    feedbackTextController.clear();
                    selectedRating = null;
                  }),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (feedbackTextController.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please enter your feedback',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    
                    final success = await feedbackController.submitFeedback(
                      feedbackType: 'artwork',
                      artworkId: widget.artwork.id,
                      rating: selectedRating,
                      comment: feedbackTextController.text,
                    );
                    
                    if (success) {
                      setState(() {
                        showFeedbackForm = false;
                        feedbackTextController.clear();
                        selectedRating = null;
                      });
                      feedbackController.fetchArtworkFeedback(widget.artwork.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackModel feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: feedback.userProfilePic != null
                      ? CachedNetworkImageProvider(
                          _buildImageUrl(feedback.userProfilePic!),
                        ) as ImageProvider
                      : const AssetImage('assets/default_avatar.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feedback.createdAt.toString().split(' ')[0],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (feedback.rating != null) ...[
              Row(
                children: List.generate(5, (index) => Icon(
                  Icons.star,
                  color: index < feedback.rating! ? Colors.amber : Colors.grey[300],
                  size: 20,
                )),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              feedback.comment,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildImageCarousel() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.width,
              viewportFraction: 1.0,
              enlargeCenterPage: true,
              enableInfiniteScroll: widget.artwork.images.length > 1,
              onPageChanged: (index, reason) {
                setState(() => _currentImageIndex = index);
              },
            ),
            items: widget.artwork.images.map((image) {
              // ignore: unnecessary_type_check
              final imageUrl = image is ArtImage ? image.image : image.toString();
              return Builder(
                builder: (context) => CachedNetworkImage(
                  imageUrl: _buildImageUrl(imageUrl),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: CircularProgressIndicator(
                      value: progress.progress,
                      color: Colors.deepPurple,
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildErrorWidget(),
                ),
              );
            }).toList(),
          ),
        ),
        if (widget.artwork.images.length > 1) _buildImageIndicators(),
        _buildFavoriteButton(),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              "Couldn't load image",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageIndicators() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.artwork.images.asMap().entries.map((entry) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentImageIndex == entry.key
                  ? Colors.deepPurple
                  : Colors.grey.withOpacity(0.4),
            ),
          );
        }).toList(),
      ),
    );
  }

  // artwork_details_page.dart
Widget _buildFavoriteButton() {
  return Positioned(
    top: 12,
    right: 12,
    child: Obx(
      () => GestureDetector(
        onTap: () async {
          final success = await favoriteController.toggleFavorite(widget.artwork.id);
          // ignore: unnecessary_null_comparison
          if (success != null) {
            Get.snackbar(
              success ? 'Added to Favorites' : 'Removed from Favorites',
              widget.artwork.title,
              snackPosition: SnackPosition.BOTTOM,
              duration: Duration(seconds: 1),
            );
          }
        },
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: Icon(
            favoriteController.isFavorite(widget.artwork.id)
                ? Icons.favorite
                : Icons.favorite_border,
            color: Colors.red,
          ),
        ),
      ),
    ),
  );
}

//   void _toggleFavorite() async {
//   if (isFavorited.value) {
//     // remove (you’ll need to track favoriteId in the model)
//     await favoriteController.removeFavorite(widget.artwork.id);
//     isFavorited.value = false;
//   } else {
//     await favoriteController.addFavorite(widget.artwork.id);
//     isFavorited.value = true;
//   }
// }


  Widget _buildArtworkDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndPrice(),
          // ignore: unnecessary_null_comparison
          if (widget.artwork.artist != null) _buildArtistInfo(),
          const Divider(height: 24),
          _buildDescription(),
          const Divider(height: 24),
          _buildCategoryInfo(),
          // ignore: unnecessary_null_comparison
          if (widget.artwork.subcategories != null && 
              widget.artwork.subcategories.isNotEmpty) _buildSubcategories(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTitleAndPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.artwork.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Text(
          '₹${widget.artwork.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildArtistInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 16),
          const SizedBox(width: 4),
          Text(
            "By ${widget.artwork.artist}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.artwork.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCategoryInfo() {
    return _buildDetailRow(
      Icons.category_outlined,
      "Category",
      widget.artwork.category.name,
    );
  }

  Widget _buildSubcategories() {
    return _buildDetailRow(
      Icons.category,
      "Subcategories",
      widget.artwork.subcategories.map((s) => s.name).join(', '),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => setState(() => quantity = quantity > 1 ? quantity - 1 : 1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('$quantity'),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => setState(() => quantity++),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _addToCart,
              child: const Text("Add to Cart"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Get.to(
            () => CheckoutPage.fromSingleItem(
              artwork: widget.artwork,
              quantity: quantity,
            ),
          ),
          child: const Text(
            'Buy Now',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _addToCart() {
    cartController.addToCart(widget.artwork.id, quantity: quantity);
    Get.snackbar(
      "Cart Updated",
      "${quantity} ${widget.artwork.title} added to cart!",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}