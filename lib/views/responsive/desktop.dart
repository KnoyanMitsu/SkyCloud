import 'package:flutter/material.dart';
import 'package:skycloud/views/feed.dart';
import 'package:skycloud/views/search.dart';
import 'package:skycloud/widget/menu.dart';

class Desktop extends StatefulWidget {
  const Desktop({super.key});

  @override
  State<Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: const Row(
          children: [
            Expanded(
              flex: 0,
              child: Menu(),
            ),
            Expanded(
              flex: 3,
              child: FeedPage(),
            ),
            Expanded(
              flex: 1,
              child: SearchPage(),
            ),
          ],
        ),
      ),
    );
  }
}

