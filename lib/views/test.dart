import 'package:flutter/material.dart';
import 'package:skycloud/widget/media.dart';

class SinglePlayerMultipleVideoWidget extends StatefulWidget {
  const SinglePlayerMultipleVideoWidget({Key? key}) : super(key: key);

  @override
  State<SinglePlayerMultipleVideoWidget> createState() =>
      _SinglePlayerMultipleVideoWidgetState();
}

class _SinglePlayerMultipleVideoWidgetState
    extends State<SinglePlayerMultipleVideoWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const VideoPlayers(
      url: "https://video.bsky.app/watch/did%3Aplc%3Acw5kssnhzktwbgtyqvqpgypn/bafkreidjosfbbhpegs3ane6qd4ksbdemzcpmqngjmxoeberh2qp27u74zi/playlist.m3u8",
      width: 500,
      height: 300,
      );
  }
}
