import 'package:artsphere/controller/customer/customerVideoController.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class CustomerReelsPage extends StatefulWidget {
  const CustomerReelsPage({Key? key}) : super(key: key);

  @override
  _CustomerReelsPageState createState() => _CustomerReelsPageState();
}

class _CustomerReelsPageState extends State<CustomerReelsPage> {
  final CustomerVideoController _videoController = Get.put(
    CustomerVideoController(),
  );
  final PageController _pageController = PageController();
  final Map<int, VideoPlayerController> _playerControllers = {};
  final Map<int, bool> _isPlaying = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _videoController.fetchAllVideos();
    _pageController.addListener(_pageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageChanged);
    _pageController.dispose();
    for (var controller in _playerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _pageChanged() {
    final newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPage) {
      // Pause current video
      if (_playerControllers.containsKey(_currentPage)) {
        _playerControllers[_currentPage]!.pause();
        setState(() {
          _isPlaying[_currentPage] = false;
        });
      }

      // Play new video
      if (_playerControllers.containsKey(newPage)) {
        _playerControllers[newPage]!.play();
        setState(() {
          _isPlaying[newPage] = true;
        });
        // Count view
        if (_videoController.allVideos.length > newPage) {
          _videoController.viewVideo(_videoController.allVideos[newPage].id);
        }
      }

      _currentPage = newPage;
    }
  }

  Future<void> _initializePlayer(int index) async {
    if (_playerControllers.containsKey(index)) return;

    final video = _videoController.allVideos[index];
    final controller = VideoPlayerController.network(video.videoFile);

    _playerControllers[index] = controller;
    _isPlaying[index] = false;

    try {
      await controller.initialize();
      if (index == 0) {
        controller.play();
        _isPlaying[index] = true;
        _videoController.viewVideo(video.id);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load video',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    if (mounted) setState(() {});
  }

  void _toggleLike(int index) {
    if (index >= _videoController.allVideos.length) return;
    final video = _videoController.allVideos[index];
    _videoController.likeVideo(video.id);
  }

  void _togglePlayPause(int index) {
    if (!_playerControllers.containsKey(index)) return;

    if (_isPlaying[index]!) {
      _playerControllers[index]!.pause();
    } else {
      _playerControllers[index]!.play();
      if (index == _currentPage) {
        _videoController.viewVideo(_videoController.allVideos[index].id);
      }
    }
    setState(() {
      _isPlaying[index] = !_isPlaying[index]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (_videoController.isLoading.value &&
            _videoController.allVideos.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (_videoController.allVideos.isEmpty) {
          return Center(
            child: Text(
              'No videos available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _videoController.allVideos.length,
          onPageChanged: (index) {
            _currentPage = index;
          },
          itemBuilder: (context, index) {
            final video = _videoController.allVideos[index];
            _initializePlayer(index);

            return Stack(
              fit: StackFit.expand,
              children: [
                // Video Player
                if (_playerControllers.containsKey(index))
                  GestureDetector(
                    onTap: () => _togglePlayPause(index),
                    child: VideoPlayer(_playerControllers[index]!),
                  )
                else
                  Container(color: Colors.black),

                // Video Info Overlay
                Positioned(
                  bottom: 80,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        video.description,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Artist Info
                Positioned(
                  bottom: 20,
                  left: 16,
                  child: Row(
                    children: [
                      CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[200],
                                child: ClipOval(
                                  child:
                                      // ignore: unnecessary_null_comparison
                                      video.artistProfilePic !=  null
                                          ? CachedNetworkImage(
                                            imageUrl:
                                                video.artistProfilePic,
                                            placeholder:
                                                (context, url) =>
                                                    const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.person),
                                            fit: BoxFit.cover,
                                            width: 110,
                                            height: 110,
                                          )
                                          : Image.asset(
                                            'assets/default_avatar.png',
                                            fit: BoxFit.cover,
                                            width: 110,
                                            height: 110,
                                          ),
                                ),
                              ),
                      SizedBox(width: 10),
                      Text(
                        video.artistName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Like Button and Count
                Positioned(
                  bottom: 20,
                  right: 16,
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          video.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: video.isLiked ? Colors.red : Colors.white,
                          size: 32,
                        ),
                        onPressed: () => _toggleLike(index),
                      ),
                      Text(
                        '${video.likesCount}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // View Count
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${video.views}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                // Play/Pause Center Button
                if (_playerControllers.containsKey(index) &&
                    !_isPlaying[index]!)
                  Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 64,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
              ],
            );
          },
        );
      }),
    );
  }
}


