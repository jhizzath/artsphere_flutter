import 'package:artsphere/controller/artist/artistVideoController.dart';
import 'package:artsphere/screens/artistView/video_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArtistVideoGridPage extends StatelessWidget {
  final ArtistVideoController controller = Get.put(ArtistVideoController());

  @override
  Widget build(BuildContext context) {
    controller.fetchMyVideos();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Videos'),
        elevation: 0,
      ),
      body: Obx(() => controller.isLoading.value
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: controller.artistVideos.length,
              itemBuilder: (context, index) {
                var video = controller.artistVideos[index];
                return GestureDetector(
                  onTap: () {
                    controller.incrementView(video.id);
                    Get.to(() => VideoDetailPage(video: video));
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Video thumbnail
                        Image.network(
                          '${controller.baseUrl}${video.thumbnail}',
                          fit: BoxFit.cover,
                        ),
                        
                        // Gradient overlay at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Video stats overlay
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Video title
                              Text(
                                video.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              // Stats row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Likes
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.favorite, 
                                            size: 14, 
                                            color: Colors.red[300]),
                                        SizedBox(width: 4),
                                        Text(
                                          '${video.likesCount}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Views
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.remove_red_eye, 
                                            size: 14, 
                                            color: Colors.blue[300]),
                                        SizedBox(width: 4),
                                        Text(
                                          '${video.views}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Play icon overlay
                        Positioned.fill(
                          child: Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              size: 48,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
    );
  }
}