import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../constants/app_colors.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool autoPlay;
  final VoidCallback? onPlayPause;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.autoPlay = false,
    this.onPlayPause,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        if (widget.autoPlay) {
          _play();
        }
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _play() {
    if (_controller != null && _isInitialized) {
      _controller!.play();
      setState(() {
        _isPlaying = true;
      });
      widget.onPlayPause?.call();
    }
  }

  void _pause() {
    if (_controller != null && _isInitialized) {
      _controller!.pause();
      setState(() {
        _isPlaying = false;
      });
      widget.onPlayPause?.call();
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Stack(
          children: [
            // Video player or thumbnail
            if (_isInitialized && _controller != null)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9, // Default aspect ratio for thumbnail
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.thumbnailUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                    ),
                  ),
                ),
              ),
            
            // Center play button overlay (always visible when paused)
            if (!_isPlaying)
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Video controls
            if (_showControls && _isInitialized && _controller != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Play/Pause button
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Progress bar
                      Expanded(
                        child: VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: AppColors.accentRed,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Duration
                      Text(
                        _formatDuration(_controller!.value.duration),
                        style: const TextStyle(
    fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

