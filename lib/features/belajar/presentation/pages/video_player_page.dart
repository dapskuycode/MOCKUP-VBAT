import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/native_security_service.dart';
import 'package:vbat_ponsel/core/utils/offline_media_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class VideoPlayerPage extends StatefulWidget {
  final String? title;
  final List<Map<String, dynamic>> playlist;
  final int currentIndex;
  final bool isPreview;
  final bool isFreeClass;
  final int? materialId;
  final String? videoUrl;

  const VideoPlayerPage({
    super.key,
    this.title,
    this.playlist = const [],
    this.currentIndex = 0,
    this.isPreview = false,
    this.isFreeClass = false,
    this.materialId,
    this.videoUrl,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  VideoPlayerController? _controller;
  bool _isPlayerReady = false;
  bool _isVideoCompleted = false;
  bool _isPlaying = false;
  double _currentPosition = 0;
  double _duration = 1; // avoid division by 0
  double _maxWatchedPosition = 0; // Anti-skip tracking for Paid LMS
  double _playbackSpeed = 1.0;
  bool _isFullScreen = false;
  bool _showPaywall = false;
  bool _hasSent70Percent = false;

  // Controls Auto-Hide State
  Timer? _hideTimer;
  bool _showControls = true;
  bool _isScrubbing = false;

  // Streams for resolution
  List<yt.MuxedStreamInfo> _availableStreams = [];
  yt.MuxedStreamInfo? _currentStream;
  bool _hasLoadError = false;
  String _resolvedVideoId = 'drcMv73jEGE';

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    if (!widget.isFreeClass) {
      NativeSecurityService.enableSecureMode();
    }
    _initVideo();
    _startHideTimer();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (_isScrubbing) return;
    _hideTimer = Timer(const Duration(seconds: 4), () {
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

  String _formatDuration(double seconds) {
    final d = Duration(seconds: seconds.toInt());
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return "${d.inHours}:$minutes:$secs";
    }
    return "$minutes:$secs";
  }

  Future<void> _initVideo() async {
    String videoId = 'drcMv73jEGE'; // Default fallback

    if (widget.materialId != null &&
        OfflineMediaManager.canPlayOffline(widget.materialId.toString())) {
      final offlineUrl = OfflineMediaManager.getDecryptedOfflineUrl(widget.materialId.toString());
      if (offlineUrl != null && offlineUrl.isNotEmpty) {
        debugPrint('[VideoPlayer] Playing authorized offline lesson: ${widget.materialId}');
      }
    }

    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      final raw = widget.videoUrl!;
      if (raw.contains('v=')) {
        videoId = raw.split('v=')[1].split('&')[0];
      } else if (raw.contains('youtu.be/')) {
        videoId = raw.split('youtu.be/')[1].split('?')[0];
      } else if (!raw.contains('/')) {
        videoId = raw;
      }
    } else if (widget.playlist.isNotEmpty &&
        widget.currentIndex >= 0 &&
        widget.currentIndex < widget.playlist.length) {
      final item = widget.playlist[widget.currentIndex];
      final raw = (item['videoUrl'] ??
              item['youtube_url'] ??
              item['youtube_video_id'] ??
              item['source_path'] ??
              '')
          .toString();
      if (raw.contains('v=')) {
        videoId = raw.split('v=')[1].split('&')[0];
      } else if (raw.contains('youtu.be/')) {
        videoId = raw.split('youtu.be/')[1].split('?')[0];
      } else if (raw.isNotEmpty && !raw.contains('/')) {
        videoId = raw;
      }
    }

    _resolvedVideoId = videoId;

    if (kIsWeb) {
      // Browser Web memiliki batasan CORS terhadap stream langsung YouTube
      if (mounted) {
        setState(() {
          _hasLoadError = true;
          _isPlayerReady = false;
        });
      }
      return;
    }

    final ytExplode = yt.YoutubeExplode();
    try {
      var manifest = await ytExplode.videos.streamsClient.getManifest(videoId);
      final streams = manifest.muxed.toList();
      streams.sort(
        (a, b) => b.videoResolution.height.compareTo(a.videoResolution.height),
      );

      final Map<int, yt.MuxedStreamInfo> uniqueStreams = {};
      for (var s in streams) {
        if (!uniqueStreams.containsKey(s.videoResolution.height)) {
          uniqueStreams[s.videoResolution.height] = s;
        }
      }

      if (mounted) {
        setState(() {
          _availableStreams = uniqueStreams.values.toList();
          _currentStream = _availableStreams.isNotEmpty
              ? _availableStreams.first
              : null;
        });
      }

      if (_currentStream != null) {
        await _loadStream(_currentStream!);
      } else {
        if (mounted) {
          setState(() {
            _hasLoadError = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading youtube video: $e");
      if (mounted) {
        setState(() {
          _hasLoadError = true;
        });
      }
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
          _controller!.setPlaybackSpeed(_playbackSpeed);
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001944),
                  ),
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
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    if (!isSelected) {
                      setState(() {
                        _currentStream = stream;
                        _isPlayerReady = false;
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

  void _showSpeedPicker() {
    final speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
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
                  "Kecepatan Pemutaran",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001944),
                  ),
                ),
              ),
              ...speeds.map((speed) {
                final isSelected = _playbackSpeed == speed;
                return ListTile(
                  title: Text("${speed}x"),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _playbackSpeed = speed;
                    });
                    _controller?.setPlaybackSpeed(speed);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _handleSeek(double targetSeconds) {
    if (_controller == null || !_isPlayerReady) return;

    // Rules: Free Class = Bebas seek. Paid LMS = Tidak boleh skip maju melebihi durasi yang sudah ditonton
    final bool isPaidLms = !widget.isFreeClass && !widget.isPreview;

    if (isPaidLms && targetSeconds > _maxWatchedPosition + 2.0) {
      // Tolak fast-forward
      _controller!.seekTo(Duration(seconds: _maxWatchedPosition.toInt()));
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.lock_clock_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Materi Berbayar: Dilarang melompati video. Tonton materi secara berurutan.",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFFF97316),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _controller!.seekTo(Duration(seconds: targetSeconds.toInt()));
    }
  }

  void _recordProgressApi(int progressPercent) async {
    final materialId = widget.materialId ?? 5;
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      await dio.post(
        '/learning-materials/$materialId/progress',
        data: {'progress_percent': progressPercent},
      );
      debugPrint("Progress $progressPercent% sent to API for material #$materialId");
    } catch (_) {}
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    final pos = _controller!.value.position.inSeconds.toDouble();

    setState(() {
      _currentPosition = pos;
      _isPlaying = _controller!.value.isPlaying;

      // Update max watched position as video plays naturally
      if (_currentPosition > _maxWatchedPosition) {
        _maxWatchedPosition = _currentPosition;
      }

      // Preview cutoff (10 detik untuk preview)
      if (widget.isPreview && _currentPosition >= 10 && !_showPaywall) {
        _showPaywall = true;
        _controller!.pause();
        return;
      }

      // Check 70% progress threshold (Client requirement REQ-LMS-03)
      final ratio = _duration > 0 ? _currentPosition / _duration : 0.0;
      if (ratio >= 0.70 && !_hasSent70Percent && !widget.isPreview) {
        _hasSent70Percent = true;
        _recordProgressApi(70);
        // Naikkan progress pembelajaran di SessionManager
        if (SessionManager.learningProgress.value < 0.75) {
          SessionManager.learningProgress.value = 0.75;
        }
      }

      // Check completion (95%+)
      if (ratio >= 0.95 && !_isVideoCompleted && !widget.isPreview) {
        _isVideoCompleted = true;
        _recordProgressApi(100);
        if (SessionManager.learningProgress.value < 0.92) {
          // Unlock 90%+ Hardware Solution
          SessionManager.learningProgress.value = 0.92;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("Selamat! Materi ini telah selesai tuntas 100%."),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    NativeSecurityService.disableSecureMode();
    _hideTimer?.cancel();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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

  Widget _buildWebFallbackArea() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F141C),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Color(0xFFE50914),
                  size: 44,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title ?? "Video Pembelajaran",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                kIsWeb
                    ? "Video YouTube dibatasi oleh kebijakan CORS di Browser Web (Chrome).\nFitur pemutar native & proteksi FLAG_SECURE aktif di HP Android / Emulator."
                    : "Gagal memuat stream video. Pastikan koneksi internet aktif.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final ytUri = Uri.parse("https://www.youtube.com/watch?v=$_resolvedVideoId");
                      if (await canLaunchUrl(ytUri)) {
                        await launchUrl(ytUri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text("Buka di YouTube"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      _recordProgressApi(100);
                      if (SessionManager.learningProgress.value < 0.92) {
                        SessionManager.learningProgress.value = 0.92;
                      }
                      setState(() {
                        _isVideoCompleted = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Simulasi tonton 100% selesai! Progres berhasil disimpan."),
                            ],
                          ),
                          backgroundColor: Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text("Simulasikan Selesai (100%)"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayerArea() {
    final bool isPaidLms = !widget.isFreeClass && !widget.isPreview;

    if (_hasLoadError) {
      return _buildWebFallbackArea();
    }

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
                  // Gradient Vignette
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Center Controls: Replay 10s, Play/Pause, Forward 10s
                  if (_isPlayerReady)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _startHideTimer();
                              _handleSeek((_currentPosition - 10).clamp(0.0, _duration));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.replay_10_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () {
                              _startHideTimer();
                              if (_isPlaying) {
                                _controller?.pause();
                              } else {
                                _controller?.play();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B4F9B).withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () {
                              _startHideTimer();
                              _handleSeek((_currentPosition + 10).clamp(0.0, _duration));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPaidLms
                                    ? Icons.lock_clock_rounded
                                    : Icons.forward_10_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Top Action Buttons: Resolution & Fullscreen
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _startHideTimer();
                            _showResolutionPicker();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            _startHideTimer();
                            _toggleFullScreen();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFullScreen
                                  ? Icons.fullscreen_exit_rounded
                                  : Icons.crop_rotate_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mode Indicator Badge on Top Left
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaidLms
                            ? const Color(0xFFF97316).withValues(alpha: 0.85)
                            : const Color(0xFF10B981).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPaidLms ? Icons.lock_rounded : Icons.lock_open_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPaidLms ? "LMS BERBAYAR (ANTI-SKIP)" : "FREE CLASS (FULL KONTROL)",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Controls Bar: Scrubber Slider, Time, and Speed
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Interactive Scrubber Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            activeTrackColor: const Color(0xFF1B4F9B),
                            inactiveTrackColor: Colors.white30,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: _currentPosition.clamp(0.0, _duration),
                            min: 0.0,
                            max: _duration,
                            onChangeStart: (_) {
                              _isScrubbing = true;
                              _hideTimer?.cancel();
                            },
                            onChanged: (val) {
                              setState(() {
                                _currentPosition = val;
                              });
                            },
                            onChangeEnd: (val) {
                              _isScrubbing = false;
                              _startHideTimer();
                              _handleSeek(val);
                            },
                          ),
                        ),

                        // Time and Speed Controls Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${_formatDuration(_currentPosition)} / ${_formatDuration(_duration)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _showSpeedPicker,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "${_playbackSpeed}x",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                ],
              ),
            ),
          ),

          // Paywall Overlay for Preview
          if (_showPaywall)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Colors.orange, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        "Waktu Preview Habis",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Beli Kelas Android atau iPhone untuk menonton video materi secara lengkap dan dapatkan KTA Permanen.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          if (_isFullScreen) _toggleFullScreen();
                          context.push('/pricelist');
                        },
                        child: const Text("Beli Paket Belajar"),
                      ),
                    ],
                  ),
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
        backgroundColor: _isDark ? ThemeManager.darkCard : _primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(_isVideoCompleted),
        ),
        title: Text(
          widget.title ?? "Video Materi",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(aspectRatio: 16 / 9, child: _buildVideoPlayerArea()),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Completion Celebration Card
                  if (_isVideoCompleted)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isDark ? Colors.green.shade800 : Colors.green.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isDark
                                  ? Colors.green.shade900.withValues(alpha: 0.3)
                                  : Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Materi Selesai 100%!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Progress pembelajaran Anda telah tersinkronisasi.",
                            style: TextStyle(fontSize: 12, color: _textGray),
                          ),
                        ],
                      ),
                    ),

                  // Material Title & Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.isFreeClass ? "FREE CLASS" : "MATERI SPESIALIS",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: widget.isFreeClass
                                    ? Colors.green
                                    : (_isDark ? const Color(0xFF60A5FA) : _primaryBlue),
                              ),
                            ),
                            ValueListenableBuilder<double>(
                              valueListenable: SessionManager.learningProgress,
                              builder: (context, prog, _) {
                                return Text(
                                  "Progress Total: ${(prog * 100).toInt()}%",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _textGray,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title ?? "Panduan Praktik Perbaikan Logic Board",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 14,
                              color: _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1B4F9B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Instruktur Resmi VBAT Central Academy",
                              style: TextStyle(fontSize: 12, color: _textGray),
                            ),
                          ],
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
}
