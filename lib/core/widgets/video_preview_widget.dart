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

  void _initVideo() {
    if (_controller != null) return;
    
    if (widget.videoUrl.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    } else {
      _controller = VideoPlayerController.asset(widget.videoUrl);
    }

    _controller!.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.setVolume(0.0); // Muted for preview
        _controller!.setLooping(true);
        _controller!.play();
      }
    }).catchError((e) {
      debugPrint("Video init error: $e");
    });
  }

  void _disposeVideo() {
    _controller?.dispose();
    _controller = null;
    if (mounted) {
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video-preview-${widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        if (info.visibleFraction > 0.4) {
          if (_controller == null) {
            _initVideo();
          } else if (_isInitialized && !_controller!.value.isPlaying) {
            _controller!.play();
          }
        } else {
          // Pause and dispose if not highly visible to save Android MediaCodec instances
          if (_controller != null) {
             _disposeVideo();
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            widget.fallbackImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.grey,
                  size: 36,
                ),
              ),
            ),
          ),
          if (_isInitialized && _controller != null)
            AnimatedOpacity(
              opacity: _isInitialized ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
