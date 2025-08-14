
import 'package:artsphere/controller/artist/artistVideoController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:artsphere/model/videoModel.dart';

class VideoDetailPage extends StatefulWidget {
  final ArtistVideo video;
  VideoDetailPage({required this.video});

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoPlayerController _playerController;
  final ArtistVideoController _videoController = Get.put(ArtistVideoController());
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _showControls = true;
  bool _showCenterPlayButton = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _playerController = VideoPlayerController.network(
          'http://192.168.145.221:8000/${widget.video.videoFile}')
        ..addListener(() {
          if (_playerController.value.isPlaying != _isPlaying) {
            setState(() {
              _isPlaying = _playerController.value.isPlaying;
              _showCenterPlayButton = !_isPlaying;
            });
          }
        });

      await _playerController.initialize();
      setState(() {
        _isLoading = false;
        _showCenterPlayButton = !_playerController.value.isPlaying;
      });
      _playerController.play();

      // Increment view count only once
      _videoController.incrementView(widget.video.id);
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load video: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[800],
        colorText: Colors.white,
      );
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_playerController.value.isPlaying) {
        _playerController.pause();
        _showCenterPlayButton = true;
      } else {
        _playerController.play();
        _showCenterPlayButton = false;
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
              ),
              SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
              SizedBox(height: 16),
              Text(
                'Failed to load video',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeVideoPlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: _playerController.value.aspectRatio,
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: VideoPlayer(_playerController),
                ),
              ),
            ),
          ),
          
          // Center play/pause button
          if (_showCenterPlayButton)
            Center(
              child: AnimatedOpacity(
                opacity: _showCenterPlayButton ? 1.0 : 0.0,
                duration: Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(24),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          
          if (_showControls)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Back button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    
                    // Video stats
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      right: 16,
                      child: Column(
                        children: [
                          _buildOverlayInfo(
                            Icons.remove_red_eye, 
                            widget.video.views.toString(),
                            Colors.blueAccent,
                          ),
                          SizedBox(height: 12),
                          _buildOverlayInfo(
                            Icons.favorite, 
                            widget.video.likesCount.toString(),
                            Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                    
                    // Video info
                    Positioned(
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.video.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.video.description,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlayInfo(IconData icon, String value, Color iconColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildVideoPlayer(),
      ),
    );
  }
}