import 'package:flutter/material.dart';
import 'package:fvp/mdk.dart';

class VideoPlayers extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const VideoPlayers({
    Key? key,
    required this.url,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<VideoPlayers> createState() => _VideoPlayersState();
}

class _VideoPlayersState extends State<VideoPlayers>
    with SingleTickerProviderStateMixin {
  late final Player player;
  late final ValueNotifier<PlaybackState> playbackState;
  late final AnimationController _controller;
  bool _showControls = true;

  String get url => widget.url;
  double get videoWidth => widget.width;
  double get videoHeight => widget.height;

  @override
  void initState() {
    super.initState();
    player = Player()
      ..media = url
      ..loop = 0
      ..state = PlaybackState.playing;

    player.updateTexture();
    playbackState = ValueNotifier(player.state);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    player.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls, // Show or hide controls on tap
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
                    player.state = player.state == PlaybackState.playing
                        ? PlaybackState.paused
                        : PlaybackState.playing;
                    setState(() {}); 
                  }

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
