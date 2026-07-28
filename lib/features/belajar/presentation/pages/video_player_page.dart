import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

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
  final Color _orangeCTA = const Color(0xFFFD761A);
  final Color _greenSuccess = const Color(0xFF22C55E);

  bool _isFullscreen = false;

  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/VIDEO-2026-07-26-21-31-11.mp4")
      ..addListener(() => setState(() {}))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
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
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Pengaturan Video", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.speed_rounded),
                title: const Text("Kecepatan Pemutaran"),
                trailing: const Text("Normal", style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  // Buka modal opsi kecepatan
                },
              ),
              ListTile(
                leading: const Icon(Icons.high_quality_rounded),
                title: const Text("Kualitas Video"),
                trailing: const Text("Otomatis (1080p)", style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. Top Bar (Simple) ---
            if (!_isFullscreen)
              Container(
                height: 56,
                color: _primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
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
                    const SizedBox(
                      width: 48,
                    ), // Spacer agar judul tetap di tengah
                  ],
                ),
              ),

            // --- 2. Video Player Area ---
            if (_isFullscreen)
              Expanded(
                child: _buildVideoPlayer(),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildVideoPlayer(),
              ),

            // --- 3. Judul & Navigasi (Scrollable) ---
            if (!_isFullscreen)
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

                  // Section Header: Materi Kursus (tanpa tab diskusi & catatan)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
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

                  // Playlist / List Materi (YouTube Style)
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
                        ),
                        const Divider(height: 1),
                        _buildPlaylistItem(
                          "4. Pengukuran & Tracking Jalur Short VCC_MAIN",
                          "35:00",
                          "9.8K views",
                          instructor: "Teknisi Senior",
                        ),
                        const Divider(height: 1),
                        _buildPlaylistItem(
                          "5. Praktek Soldering & Reballing IC CPU Snapdragon",
                          "45:12",
                          "18.4K views",
                          instructor: "Mas VBat",
                        ),
                        const Divider(height: 1),
                        _buildPlaylistItem(
                          "6. Final Quality Control & Perakitan Ulang Device",
                          "28:40",
                          "6.4K views",
                          instructor: "Instruktur Borneo",
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
                            onPressed: null, // Disabled state
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
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Memutar materi selanjutnya..."),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              _controller.seekTo(Duration.zero);
                              _controller.play();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: _primaryBlue, width: 1.5),
                              foregroundColor: _primaryBlue,
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

  // --- Helper Widgets ---

  Widget _buildVideoPlayer() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: _isInitialized
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _isInitialized 
                          ? VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: _orangeCTA,
                                backgroundColor: Colors.white30,
                                bufferedColor: Colors.white54,
                              ),
                            )
                          : LinearProgressIndicator(
                              value: 0,
                              color: _orangeCTA,
                              backgroundColor: Colors.white30,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            },
                            child: Icon(
                              _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              final pos = _controller.value.position;
                              _controller.seekTo(pos - const Duration(seconds: 10));
                            },
                            child: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              final pos = _controller.value.position;
                              _controller.seekTo(pos + const Duration(seconds: 10));
                            },
                            child: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isInitialized
                                ? "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}"
                                : "00:00 / 00:00",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showSettingsModal,
                            child: const Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _toggleFullscreen,
                            child: Icon(
                              _isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
        if (!isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Memutar materi: $title"),
              duration: const Duration(seconds: 2),
            ),
          );
          _controller.seekTo(Duration.zero);
          _controller.play();
        }
      },
      child: Container(
        color: isActive ? _primaryBlue.withValues(alpha: 0.05) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Thumbnail bergaya YouTube (Statis, tanpa preview video gerak) ---
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
                  // Badge Durasi di pojok kanan bawah thumbnail
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
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
                  // Overlay ikon play jika aktif
                  if (isActive)
                    Container(
                      decoration: BoxDecoration(
                        color: _primaryBlue.withValues(alpha: 0.4),
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
            // --- 2. Judul & Info Kanan (YouTube Style) ---
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
            // --- 3. Ikon Menu 3-titik (YouTube Style) ---
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
