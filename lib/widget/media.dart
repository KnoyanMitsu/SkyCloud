import 'package:flutter/material.dart';
import 'package:fvp/mdk.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayers extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const VideoPlayers({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  State<VideoPlayers> createState() => _VideoPlayersState();
}

class _VideoPlayersState extends State<VideoPlayers>
    with SingleTickerProviderStateMixin {
  late Player player; // Tetap gunakan `late`, tapi segera inisialisasi
  late final ValueNotifier<PlaybackState> playbackState;
  late final AnimationController _controller;
  bool _isVideoVisible = false; // State untuk mengetahui apakah video terlihat
  bool _isVideoLoaded = false;

  String get url => widget.url;
  double get videoWidth => widget.width;
  double get videoHeight => widget.height;

  @override
  void initState() {
    super.initState();
    player = Player(); // Inisialisasi terlebih dahulu

    playbackState = ValueNotifier(PlaybackState.stopped);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    if (_isVideoLoaded) player.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat video ketika terlihat
  void _loadVideo() {
    player
      ..media = url
      ..loop = 0
      ..state = PlaybackState.playing;

    player.updateTexture();
    _isVideoLoaded = true;
    playbackState.value = PlaybackState.playing;
  }

  // Fungsi untuk menghentikan video jika tidak terlihat
  void _disposeVideo() {
    if (_isVideoLoaded) {
      player.dispose();
      _isVideoLoaded = false;
      playbackState.value = PlaybackState.stopped;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(url),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 50 && !_isVideoVisible) {
          _loadVideo(); // Load video ketika terlihat lebih dari 50%
          _isVideoVisible = true;
        } else if (visiblePercentage <= 50 && _isVideoVisible) {
          _disposeVideo(); // Dispose video ketika tidak terlihat
          _isVideoVisible = false;
        }
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (player.state == PlaybackState.playing) {
              player.state = PlaybackState.paused;
            } else {
              player.state = PlaybackState.playing;
            }
          }); 
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Container
            Container(
              width: videoWidth,
              height: videoHeight,
              color: Colors.black,
              child: ValueListenableBuilder<int?>(
                valueListenable: player.textureId,
                builder: (context, id, _) {
                  if (id == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Texture(textureId: id);
                  }
                },
              ),
            ),
            // Play/Pause button in the center with fade animation
            FadeTransition(
              opacity: _controller,
              child: Container(
                width: videoWidth,
                height: videoHeight,
                color: Colors.black54,
                child: ValueListenableBuilder<PlaybackState>(
                valueListenable: playbackState,
                builder: (context, state, _) {
                  return IconButton(
                    iconSize: 64.0,
                    icon: Icon(
                      player.state == PlaybackState.playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (player.state == PlaybackState.playing) {
                        player.state = PlaybackState.paused;
                      } else {
                        player.state = PlaybackState.playing;
                      }
                      setState(() {});
                    },
                  );
                },
              ),
              )
            ),
          ],
        ),
      ),
    );
  }
}
