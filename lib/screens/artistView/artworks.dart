import 'package:artsphere/controller/artist/artworkController.dart';
import 'package:artsphere/model/artworkModel.dart';
import 'package:artsphere/screens/artistView/artworkDetail.dart';
import 'package:artsphere/screens/artistView/feedbackPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyArtworks extends StatelessWidget {
  final ArtworkController _controller = Get.put(ArtworkController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Colors.white,
        title: const Center(child: Text("My Artworks")),
        actions: [
          Obx(() => Switch(
                value: _controller.showAllArtworks.value,
                onChanged: (value) => _controller.toggleShowAll(),
                activeColor: Colors.green,
              )),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.fetchArtistArtworks(),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          _controller.showAllArtworks.value 
                              ? "Showing All Artworks" 
                              : "Showing Approved Only",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: _controller.artworksList.isEmpty
                    ? const Center(child: Text("No artworks found"))
                    : ListView.builder(
                        itemCount: _controller.artworksList.length,
                        itemBuilder: (context, index) {
                          final artwork = _controller.artworksList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              tileColor: Colors.white,
                              leading: SizedBox(
                                width: 60,
                                height: 60,
                                child: _buildArtworkImage(artwork),
                              ),
                              title: Text(artwork.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                        "Price: ₹${artwork.price.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // Text(
                                      //   "Price: ₹${artwork.price.toStringAsFixed(2)}",
                                      //   style: TextStyle(
                                      //     color: Colors.grey[700],
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                      // const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: artwork.isApproved 
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          artwork.approvalStatus,
                                          style: TextStyle(
                                            color: artwork.isApproved 
                                                ? Colors.green 
                                                : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Text("Qty: ${artwork.count}"),
                              // onTap: () {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => ArtworkFeedbackPage(
                              //         artworkId: artwork.id,
                              //         artworkTitle: artwork.title,
                              //         artworkImage: artwork.images.isNotEmpty 
                              //             ? artwork.images.first.image 
                              //             : '',
                              //       ),
                              //     ),
                              //   );
                              // },
                              onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
        builder: (context) => ArtworkDetailsScreen(artwork: artwork),
            ),
          );
        },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildArtworkImage(ArtworkModel artwork) {
    if (artwork.images.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 30),
              SizedBox(height: 4),
              Text(
                'No image',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: artwork.images.first.image,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.white,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          return Container(
            color: Colors.grey,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 30),
                SizedBox(height: 4),
                Text(
                  'Image unavailable',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
