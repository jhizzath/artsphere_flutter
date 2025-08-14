import 'package:artsphere/controller/feedbackController.dart';
import 'package:artsphere/model/artworkModel.dart';
import 'package:artsphere/model/feedbackModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ArtworkDetailsScreen extends StatefulWidget {
  final ArtworkModel artwork;

  const ArtworkDetailsScreen({Key? key, required this.artwork}) : super(key: key);

  @override
  State<ArtworkDetailsScreen> createState() => _ArtworkDetailsScreenState();
}

class _ArtworkDetailsScreenState extends State<ArtworkDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FeedbackController feedbackController = Get.put(FeedbackController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    feedbackController.fetchArtworkFeedback(widget.artwork.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artwork.title),
        backgroundColor:  Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details', icon: Icon(Icons.info_outline)),
            Tab(text: 'Feedback', icon: Icon(Icons.reviews)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildFeedbackTab(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      child: Container(
        color: const Color(0xFFF5F7FA),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Artwork Image
              _buildArtworkImage(widget.artwork),
              
              const SizedBox(height: 20),
              
              // Title and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.artwork.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.artwork.isApproved 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.artwork.approvalStatus,
                      style: TextStyle(
                        color: widget.artwork.isApproved ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Artist and Category
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    widget.artwork.artist,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  const Icon(Icons.category_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    widget.artwork.category.name,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Price and Quantity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Price",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "₹${widget.artwork.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Available Quantity",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.artwork.count.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Description
              const Text(
                "Description",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.artwork.description,
                style: const TextStyle(fontSize: 16),
              ),
              
              const SizedBox(height: 20),
              
              // Subcategories
              if (widget.artwork.subcategories.isNotEmpty) ...[
                const Text(
                  "Tags",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.artwork.subcategories
                      .map((subcategory) => Chip(
                            label: Text(subcategory.name),
                            backgroundColor: Colors.grey[200],
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return Obx(() {
      if (feedbackController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (feedbackController.feedbackList.isEmpty) {
        return const Center(child: Text('No feedback for this artwork'));
      }

      final feedbacks = feedbackController.feedbackList;
      final ratingFeedbacks = feedbacks.where((f) => f.rating != null).toList();
      final averageRating = ratingFeedbacks.isNotEmpty
          ? ratingFeedbacks.map((f) => f.rating!).reduce((a, b) => a + b) / ratingFeedbacks.length
          : 0.0;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.artwork.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${feedbacks.length} reviews',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildRatingStars(averageRating.round()),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                return _buildFeedbackItem(feedbacks[index]);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildArtworkImage(ArtworkModel artwork) {
    if (artwork.images.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 50),
              SizedBox(height: 8),
              Text('No image available'),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: artwork.images.first.image,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 300,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 300,
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 50),
                SizedBox(height: 8),
                Text('Failed to load image'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackItem(FeedbackModel feedback) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: feedback.userProfilePic != null
                      ? NetworkImage(feedback.userProfilePic!)
                      : null,
                  child: feedback.userProfilePic == null
                      ? Text(feedback.userName.substring(0, 1).toUpperCase())
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  feedback.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (feedback.rating != null)
                  _buildRatingStars(feedback.rating!),
              ],
            ),
            const SizedBox(height: 8),
            Text(feedback.comment),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM d, y hh:mm a').format(feedback.createdAt),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }
}