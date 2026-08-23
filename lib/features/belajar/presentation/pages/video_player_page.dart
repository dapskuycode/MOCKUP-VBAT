import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:go_router/go_router.dart';
import 'dart:async';

class VideoPlayerPage extends StatefulWidget {
  final String? title;
  final List<Map<String, dynamic>> playlist;
  final int currentIndex;

  const VideoPlayerPage({
    super.key, 
    this.title, 
    this.playlist = const [],
    this.currentIndex = 0,
  });

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

  // Controls Auto-Hide State
  Timer? _hideTimer;
  bool _showControls = true;

  // Streams for resolution
  List<yt.MuxedStreamInfo> _availableStreams = [];
  yt.MuxedStreamInfo? _currentStream;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  Future<void> _initVideo() async {
    final ytExplode = yt.YoutubeExplode();
    try {
      const videoId = 'drcMv73jEGE'; // Updated Video ID from User
      var manifest = await ytExplode.videos.streamsClient.getManifest(videoId);
      
      final streams = manifest.muxed.toList();
      streams.sort((a, b) => b.videoResolution.height.compareTo(a.videoResolution.height));
      
      final Map<int, yt.MuxedStreamInfo> uniqueStreams = {};
      for (var s in streams) {
        if (!uniqueStreams.containsKey(s.videoResolution.height)) {
          uniqueStreams[s.videoResolution.height] = s;
        }
      }

      if (mounted) {
        setState(() {
          _availableStreams = uniqueStreams.values.toList();
          _currentStream = _availableStreams.isNotEmpty ? _availableStreams.first : null;
        });
      }

      if (_currentStream != null) {
        await _loadStream(_currentStream!);
      }
    } catch (e) {
      debugPrint("Error loading youtube video: $e");
    } finally {
      ytExplode.close();
    }
  }

  Future<void> _loadStream(yt.MuxedStreamInfo stream) async {
    final oldPosition = _controller?.value.position;
    final wasPlaying = _controller?.value.isPlaying ?? true;
    
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    
    _controller = VideoPlayerController.networkUrl(stream.url)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _duration = _controller!.value.duration.inSeconds.toDouble();
          if (_duration == 0) _duration = 1;
          _isPlayerReady = true;
          
          if (oldPosition != null) {
            _controller!.seekTo(oldPosition);
            _currentPosition = oldPosition.inSeconds.toDouble();
          }
          if (wasPlaying) {
             _isPlaying = true;
             _controller!.play();
          }
        });
        
        _controller!.addListener(_videoListener);
      });
  }

  void _showResolutionPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Pilih Resolusi Video",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF001944)),
                ),
              ),
              if (_availableStreams.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Resolusi lain tidak tersedia."),
                ),
              ..._availableStreams.map((stream) {
                final isSelected = _currentStream == stream;
                return ListTile(
                  leading: const Icon(Icons.hd_rounded, color: Colors.blueGrey),
                  title: Text("${stream.videoResolution.height}p"),
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.green) : null,
                  onTap: () {
                    Navigator.pop(context);
                    if (!isSelected) {
                      setState(() {
                        _currentStream = stream;
                        _isPlayerReady = false; // Show loading indicator briefly
                      });
                      _loadStream(stream);
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
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
    _hideTimer?.cancel();
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
    return GestureDetector(
      onTap: _toggleControls,
      behavior: HitTestBehavior.opaque,
      child: Stack(
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
          
          // Custom Overlay Controls (Fade Animation)
          IgnorePointer(
            ignoring: !_showControls,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Stack(
                children: [
                  if (_isPlayerReady)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _startHideTimer(); // Reset timer on click
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
                              _startHideTimer(); // Reset timer on click
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
                              _startHideTimer(); // Reset timer on click
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
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _startHideTimer();
                            _showResolutionPicker();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            _startHideTimer(); // Reset timer on click
                            _toggleFullScreen();
                          },
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
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  if (_isVideoCompleted)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 48,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Selesai Menonton?",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF001944),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Materi berikutnya hanya akan terbuka jika materi ini telah selesai.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                context.pop(true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "KONFIRMASI SELESAI",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Text(
                    "Materi Selanjutnya",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001944),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final effectivePlaylist = widget.playlist.isNotEmpty 
                        ? widget.playlist 
                        : [
                            {"type": "video", "title": "1. Pengenalan Alat Dasar", "duration": "12:45"},
                            {"type": "video", "title": "2. Standar Keselamatan (K3)", "duration": "08:20"},
                            {"type": "video", "title": "3. Penggunaan Multimeter", "duration": "15:30"},
                            {"type": "quiz", "title": "Kuis: Alat & Keselamatan"},
                          ];
                      
                      if (effectivePlaylist.length > widget.currentIndex + 1) {
                        return Column(
                          children: effectivePlaylist.skip(widget.currentIndex + 1).map((item) {
                            final isQuiz = item['type'] == 'quiz';
                            final defaultDuration = isQuiz ? "Mandatori" : "10:00";
                            final imgUrl = isQuiz 
                              ? "https://img.freepik.com/free-vector/quiz-word-concept_23-2147844150.jpg" 
                              : "https://img.youtube.com/vi/drcMv73jEGE/mqdefault.jpg";

                            return _buildNextVideoItem(
                              title: item['title'].toString(),
                              duration: item['duration']?.toString() ?? defaultDuration,
                              thumbnailUrl: imgUrl,
                            );
                          }).toList(),
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              "Anda berada di materi terakhir.",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextVideoItem({required String title, required String duration, required String thumbnailUrl}) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Terkunci! Selesaikan video saat ini terlebih dahulu."),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                thumbnailUrl,
                width: 100,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 56,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001944),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.lock_rounded, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
