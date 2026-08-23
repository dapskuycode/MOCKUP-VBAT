import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class VideoPlayerPage extends StatefulWidget {
  final String? title;
  const VideoPlayerPage({super.key, this.title});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);
  final Color _greenSuccess = const Color(0xFF22C55E);

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
      const videoId = 'YHAV-1jWRrY';
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

  @override
  Widget build(BuildContext context) {
    // Jika fullscreen, tampilkan hanya video player (mengisi layar)
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildVideoPlayerArea(),
      );
    }

    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. Top Bar ---
            Container(
              height: 56,
              color: _primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.title ?? "Mastering iPhone 13 Screen Repair",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // --- 2. Video Player Area (Native MP4) ---
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildVideoPlayerArea(),
            ),

            // --- 3. Judul & Navigasi (Scrollable) ---
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  // Info Video
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "1. Pengenalan Alat & K3",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Mastering iPhone 13 Screen Repair > Modul 1",
                          style: TextStyle(
                            fontSize: 12,
                            color: _primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Section Header: Materi Kursus
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.playlist_play_rounded, color: _primaryBlue, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "Materi Kursus",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Playlist
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildPlaylistItem(
                          "1. Pengenalan Alat & K3 dalam Servis Ponsel",
                          "15:30",
                          "12.5K views",
                          instructor: "Mas VBat",
                          isActive: true,
                        ),
                        const Divider(height: 1),
                        _buildPlaylistItem(
                          "2. Keamanan Baterai & Mencegah Korsleting",
                          "10:45",
                          "8.1K views",
                          instructor: "Mas VBat",
                          isCompleted: true,
                        ),
                        const Divider(height: 1),
                        _buildPlaylistItem(
                          "3. Teknik Membuka Segel Layar iPhone 13 Pro Max",
                          "22:10",
                          "15.2K views",
                          instructor: "Mas VBat",
                          isLocked: true,
                        ),
                      ],
                    ),
                  ),

                  // Navigasi Next/Prev
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.skip_previous_rounded),
                            label: const Text("Sebelumnya"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isVideoCompleted ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Memutar materi selanjutnya..."),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              _controller?.seekTo(Duration.zero);
                              _controller?.play();
                            } : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Harap tonton video hingga selesai!"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: _isVideoCompleted ? _primaryBlue : Colors.grey, width: 1.5),
                              foregroundColor: _isVideoCompleted ? _primaryBlue : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.skip_next_rounded),
                            label: const Text(
                              "Selanjutnya",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        
        // Custom Overlay Controls di tengah (Hanya 3 tombol)
        if (_isPlayerReady)
          Positioned.fill(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tombol mundur 10 detik
                  GestureDetector(
                    onTap: () {
                      final newPos = (_currentPosition - 10).clamp(0.0, _duration);
                      _controller?.seekTo(Duration(seconds: newPos.toInt()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Tombol Play / Pause
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
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Tombol maju 10 detik
                  GestureDetector(
                    onTap: () {
                      final newPos = (_currentPosition + 10).clamp(0.0, _duration);
                      _controller?.seekTo(Duration(seconds: newPos.toInt()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Tombol Fullscreen di pojok kanan atas
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: _toggleFullScreen,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
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

  Widget _buildPlaylistItem(
    String title,
    String duration,
    String views, {
    String instructor = "Mas VBat",
    String thumbnail = "assets/images/course_soldering.png",
    bool isActive = false,
    bool isCompleted = false,
    bool isLocked = false,
  }) {
    return InkWell(
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Materi terkunci.")));
          return;
        }
        if (!isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Memutar materi: $title"),
              duration: const Duration(seconds: 2),
            ),
          );
          _controller?.seekTo(Duration.zero);
          _controller?.play();
        }
      },
      child: Container(
        color: isActive ? _primaryBlue.withOpacity(0.05) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              height: 74,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      thumbnail,
                      fit: BoxFit.cover,
                      width: 130,
                      height: 74,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      decoration: BoxDecoration(
                        color: _primaryBlue.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                ],
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      color: _textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isActive) ...[
                        Icon(Icons.play_circle_fill_rounded, size: 14, color: _primaryBlue),
                        const SizedBox(width: 4),
                      ] else if (isCompleted) ...[
                        Icon(Icons.check_circle_rounded, size: 14, color: _greenSuccess),
                        const SizedBox(width: 4),
                      ] else if (isLocked) ...[
                        Icon(Icons.lock_rounded, size: 14, color: _textGray),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        instructor,
                        style: TextStyle(
                          fontSize: 12,
                          color: _textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    views,
                    style: TextStyle(
                      fontSize: 12,
                      color: _textGray,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.more_vert,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
