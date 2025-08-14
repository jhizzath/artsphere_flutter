// views/artist_feedback_page.dart
import 'package:artsphere/controller/artist/artistFeedbackController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:artsphere/model/feedbackModel.dart';

class ArtistFeedbackPage extends StatelessWidget {
  final ArtistFeedbackController controller = Get.put(ArtistFeedbackController());

  ArtistFeedbackPage({super.key}) {
    controller.fetchArtistFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artwork Feedback'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.feedbackList.isEmpty) {
          return const Center(child: Text('No feedback received yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.feedbackList.length,
          itemBuilder: (context, index) {
            return _buildFeedbackCard(controller.feedbackList[index]);
          },
        );
      }),
    );
  }

  Widget _buildFeedbackCard(FeedbackModel feedback) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: feedback.userProfilePic != null
                      ? NetworkImage(feedback.userProfilePic!)
                      : null,
                  child: feedback.userProfilePic == null
                      ? Text(feedback.userName.substring(0, 1))
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, y').format(feedback.createdAt),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (feedback.rating != null) _buildRatingStars(feedback.rating!),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feedback.comment,
              style: const TextStyle(fontSize: 15),
            ),
            if (feedback.artworkId != null) ...[
              const SizedBox(height: 12),
              Text(
                'Artwork ID: ${feedback.artworkId}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _reportFeedback(feedback.id),
                icon: const Icon(Icons.flag, size: 16),
                label: const Text('Report'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
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
          size: 20,
        );
      }),
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter & Sort Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter by type:'),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.filterType.value,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Feedback')),
                DropdownMenuItem(value: 'artwork', child: Text('Artwork Feedback')),
                DropdownMenuItem(value: 'app', child: Text('App Feedback')),
                DropdownMenuItem(value: 'bug', child: Text('Bug Reports')),
                DropdownMenuItem(value: 'suggestion', child: Text('Suggestions')),
              ],
              onChanged: (value) => controller.filterType.value = value!,
            )),
            const SizedBox(height: 16),
            const Text('Sort by:'),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.sortBy.value,
              items: [
                const DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                const DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                if (controller.filterType.value == 'artwork') ...[
                  const DropdownMenuItem(value: 'highest', child: Text('Highest Rating')),
                  const DropdownMenuItem(value: 'lowest', child: Text('Lowest Rating')),
                ],
              ],
              onChanged: (value) => controller.sortBy.value = value!,
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.applyFilters(
                controller.filterType.value,
                controller.sortBy.value,
              );
              Get.back();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _reportFeedback(int feedbackId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Report Feedback'),
        content: const Text('Are you sure you want to report this feedback?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.reportFeedback(feedbackId);
    }
  }
}