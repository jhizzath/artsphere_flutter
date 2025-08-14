import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.looping = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isInitializing = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoController = VideoPlayerController.network(widget.videoUrl)
        ..addListener(_videoListener);

      await _videoController.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _chewieController = ChewieController(
            videoPlayerController: _videoController,
            autoPlay: widget.autoPlay,
            looping: widget.looping,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
        });
      }
      debugPrint('Video initialization error: $e');
    }
  }

  void _videoListener() {
    if (_videoController.value.hasError && !_hasError && mounted) {
      setState(() => _hasError = true);
    }
  }

  Future<void> _disposeControllers() async {
    _videoController.removeListener(_videoListener);
    _videoController.dispose(); // No await here
     _chewieController?.dispose(); // Keep await here
    _chewieController = null;
  }

  @override
  void dispose() {
    _disposeControllers(); // No await here either
    super.dispose();
  }

  Future<void> _retryLoading() async {
    if (mounted) setState(() {
      _isInitializing = true;
      _hasError = false;
    });
    await _disposeControllers();
    await _initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }
    return Chewie(controller: _chewieController!);
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          const Text('Video load failed', style: TextStyle(color: Colors.white)),
          TextButton(
            onPressed: _retryLoading,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}