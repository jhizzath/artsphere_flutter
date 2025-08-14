
import 'package:artsphere/controller/feedbackController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:artsphere/model/feedbackModel.dart';

class ArtworkFeedbackPage extends StatelessWidget {
  final int artworkId;
  final String artworkTitle;
  final String? artworkImage;

  ArtworkFeedbackPage({
    Key? key,
    required this.artworkId,
    required this.artworkTitle,
    this.artworkImage,
  }) : super(key: key);

  final controller = Get.put(FeedbackController());

  @override
  Widget build(BuildContext context) {
    controller.fetchArtworkFeedback(artworkId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback for $artworkTitle'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.feedbackList.isEmpty) {
          return const Center(child: Text('No feedback for this artwork'));
        }

        final feedbacks = controller.feedbackList;
        final ratingFeedbacks = feedbacks.where((f) => f.rating != null).toList();
        final averageRating = ratingFeedbacks.isNotEmpty
            ? ratingFeedbacks.map((f) => f.rating!).reduce((a, b) => a + b) / ratingFeedbacks.length
            : 0.0;

        return Column(
          children: [
            if (artworkImage != null)
              Image.network(
                artworkImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artworkTitle,
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
      }),
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
