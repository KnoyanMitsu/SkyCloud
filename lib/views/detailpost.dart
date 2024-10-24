// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skycloud/controller/detailpost.dart';
import 'package:skycloud/widget/fullimage.dart';
import 'package:skycloud/widget/media.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    super.key,
    required this.uri,
  });

  final String uri;

  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  late Map<String, dynamic> post;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetailPost();
  }

  Future<void> _fetchDetailPost() async {
    try {
      post = await Detailpost().getDetailPost(widget.uri);
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final author = post['author'];
    final desc = post['record']['text'];
    final embed = post['embed'];
    String? thumbUrl;
    String? fullUrl;

    if (embed != null && embed['images'] != null && embed['images'].isNotEmpty) {
      thumbUrl = embed['images'][0]['thumb'];
      fullUrl = embed['images'][0]['fullsize'];
    }

    bool isVideo = embed != null && embed['playlist'] != null && embed['playlist'].endsWith('.m3u8');

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/profile', arguments: author['did']);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(author['avatar']),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(author['displayName'],
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 5),
                          Text(
                            author['handle'].length > 10
                                ? '${author['handle'].substring(0, 10)}...'
                                : author['handle'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox()
                        ],
                      ),
                      desc != null ? Text(desc) : Container(),
                      const SizedBox(height: 10),
                      isVideo
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 430,
                                height: 300,
                                child: VideoPlayers(
                                  url: embed['playlist'],
                                  width: 500,
                                  height: 300,
                                  thumb: embed['thumbnail'],
                                ),
                              ),
                            )
                          : thumbUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FullImagePage(
                                            imageUrl: fullUrl!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: thumbUrl,
                                      height: 300,
                                      width: 430,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.favorite_outline),
                                onPressed: () {},
                              ),
                              Text(post['likeCount'] >= 10000000
                                  ? '${(post['likeCount'] / 10000000).toStringAsFixed(1)}M'
                                  : post['likeCount'] >= 1000
                                      ? '${(post['likeCount'] / 1000).toStringAsFixed(0)}k'
                                      : post['likeCount'].toString()),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share_outlined),
                                onPressed: () {},
                              ),
                              Text(post['repostCount'] >= 10000000
                                  ? '${(post['repostCount'] / 10000000).toStringAsFixed(1)}M'
                                  : post['repostCount'] >= 1000
                                      ? '${(post['repostCount'] / 1000).toStringAsFixed(0)}k'
                                      : post['repostCount'].toString()),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.comment_outlined),
                                onPressed: () {},
                              ),
                              Text(post['replyCount'] >= 10000000
                                  ? '${(post['replyCount'] / 10000000).toStringAsFixed(1)}M'
                                  : post['replyCount'] >= 1000
                                      ? '${(post['replyCount'] / 1000).toStringAsFixed(0)}k'
                                      : post['replyCount'].toString()),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
