import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
    // Dinonaktifkan untuk mencegah crash MediaCodec pada Android karena
    // banyaknya instance video player yang dibuat secara bersamaan pada list
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
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
    );
  }
}
