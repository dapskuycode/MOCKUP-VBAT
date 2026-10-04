import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPreviewWidget extends StatefulWidget {
  final String videoUrl;
  final String fallbackImage;

  const VideoPreviewWidget({
    super.key,
    required this.videoUrl,
    required this.fallbackImage,
  });

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeVideo();
      _initVideo();
    }
  }

  void _initVideo() {
    if (_controller != null) return;

    try {
      if (widget.videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        _controller = VideoPlayerController.asset(
          widget.videoUrl,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }

      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _hasError = false;
          });
          _controller!.setVolume(0.0); // Muted required for browser autoplay
          _controller!.setLooping(true);
          _controller!.play();
        }
      }).catchError((e) {
        debugPrint("Video init error: $e");
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
    } catch (e) {
      debugPrint("Video setup error: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _disposeVideo() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video-preview-${widget.videoUrl.hashCode}'),
      onVisibilityChanged: (info) {
        if (!mounted || _controller == null || !_isInitialized) return;
        if (info.visibleFraction > 0.3) {
          if (!_controller!.value.isPlaying) {
            _controller!.play();
          }
        } else {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background placeholder while loading or error
          widget.fallbackImage.startsWith('http')
              ? Image.network(
                  widget.fallbackImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Icon(
                        Icons.videocam_rounded,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),
                  ),
                )
              : Image.asset(
                  widget.fallbackImage.isNotEmpty ? widget.fallbackImage : 'assets/images/PHOTO-2026-07-22-20-21-55.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Icon(
                        Icons.videocam_rounded,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),
                  ),
                ),

          // Video Player
          if (_isInitialized && _controller != null)
            AnimatedOpacity(
              opacity: _isInitialized ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 400,
                  height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 200,
                  child: IgnorePointer(
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),

          // Loading indicator when preparing video
          if (!_isInitialized && !_hasError)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Video Badge Overlay
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.play_circle_filled_rounded,
                    color: Colors.redAccent,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "VIDEO PROMO",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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
}
