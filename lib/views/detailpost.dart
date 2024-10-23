// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skycloud/controller/detailpost.dart';
import 'package:skycloud/widget/fullimage.dart';
import 'package:skycloud/widget/media.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({
    super.key,
    required this.uri,
  });

  final String uri;

  @override
  Widget build(BuildContext context) {
    final detailPostController = Detailpost();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: detailPostController.getDetailPost(uri),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 9),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          final post = snapshot.data!;
          final author = post['author'];
          final description = post['record']['text'];
          final embed = post['embed'];
          String? thumbnailUrl;
          String? fullImageUrl;

          if (embed != null && embed['images'] != null && embed['images'].isNotEmpty) {
            thumbnailUrl = embed['images'][0]['thumb'];
            fullImageUrl = embed['images'][0]['fullsize'];
          }

          bool isVideo = embed != null && embed['playlist'] != null && embed['playlist'].endsWith('.m3u8');

          return Padding(
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
                              Text(
                                author['displayName'],
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                          Text(
                            "@${author['handle']}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, color: Color.fromARGB(169, 255, 255, 255)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (description != null) Text(description),
                isVideo
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 300,
                          child: VideoPlayers(
                            url: embed['playlist'],
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 300,
                            thumb: embed['thumbnail'],
                          ),
                        ),
                      )
                    : thumbnailUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullImagePage(imageUrl: fullImageUrl!),
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl: thumbnailUrl,
                                height: 300,
                                width: MediaQuery.of(context).size.width * 0.9,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(),
                const SizedBox(height: 5),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_outline),
                          onPressed: () {},
                        ),
                        Text(
                          _formatCount(post['likeCount']),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {},
                        ),
                        Text(
                          _formatCount(post['repostCount']),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment_outlined),
                          onPressed: () {},
                        ),
                        Text(
                          _formatCount(post['replyCount']),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                const Center(
                  child: Text("TODO COMMENT"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000000) {
      return '${(count / 10000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}k';
    } else {
      return count.toString();
    }
  }
}

