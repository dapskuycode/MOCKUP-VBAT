import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:go_router/go_router.dart';

class VideoPlayerPage extends StatefulWidget {
  final String? title;
  const VideoPlayerPage({super.key, this.title});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);

  VideoPlayerController? _controller;
  bool _isPlayerReady = false;
  bool _isVideoCompleted = false;
  bool _isPlaying = false;
  double _currentPosition = 0;
  double _duration = 1; // avoid division by 0
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final ytExplode = yt.YoutubeExplode();
    try {
      const videoId = 'YHAV-1jWRrY'; // Dummy video ID
      var manifest = await ytExplode.videos.streamsClient.getManifest(videoId);
      var streamInfo = manifest.muxed.withHighestBitrate();
      
      _controller = VideoPlayerController.networkUrl(streamInfo.url)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {
            _duration = _controller!.value.duration.inSeconds.toDouble();
            if (_duration == 0) _duration = 1;
            _isPlayerReady = true;
            _isPlaying = true;
          });
          _controller!.play();
          
          _controller!.addListener(_videoListener);
        });
    } catch (e) {
      debugPrint("Error loading youtube video: $e");
    } finally {
      ytExplode.close();
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    setState(() {
      _currentPosition = _controller!.value.position.inSeconds.toDouble();
      _isPlaying = _controller!.value.isPlaying;
      
      if (_currentPosition >= _duration - 1 && _duration > 1 && !_isVideoCompleted) {
        _isVideoCompleted = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Selamat! Materi ini telah selesai."),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  Widget _buildVideoPlayerArea() {
    return Stack(
      children: [
        if (_isPlayerReady && _controller != null)
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          ),
        
        // Custom Overlay Controls
        if (_isPlayerReady)
          Positioned.fill(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      final newPos = (_currentPosition - 10).clamp(0.0, _duration);
                      _controller?.seekTo(Duration(seconds: newPos.toInt()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                      child: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () {
                      if (_isPlaying) {
                        _controller?.pause();
                      } else {
                        _controller?.play();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () {
                      final newPos = (_currentPosition + 10).clamp(0.0, _duration);
                      _controller?.seekTo(Duration(seconds: newPos.toInt()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                      child: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                ],
              ),
            ),
          ),

        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: _toggleFullScreen,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
              child: Icon(
                _isFullScreen ? Icons.fullscreen_exit_rounded : Icons.crop_rotate_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildVideoPlayerArea(),
      );
    }

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(false),
        ),
        title: Text(
          widget.title ?? "Video Materi",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildVideoPlayerArea(),
            ),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 64,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Selesai Menonton?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF001944),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Konfirmasi jika Anda sudah memahami materi ini. Materi berikutnya hanya akan terbuka jika materi ini telah selesai.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // Tutup dan kembalikan nilai true ke halaman playlist module
                          context.pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "KONFIRMASI SELESAI",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
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
}
