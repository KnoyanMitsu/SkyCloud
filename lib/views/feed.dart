// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skycloud/controller/feed.dart';
import 'package:skycloud/widget/fullimage.dart';

import '../widget/media.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  final Feed feedController = Feed();
  List<dynamic> _feed = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;  // Status ketika mengambil data baru

  final ScrollController _scrollController = ScrollController();  // Tambahkan ScrollController

  @override
  void initState() {
    super.initState();
    _fetchFeed();  // Memanggil feed ketika halaman dimuat
    _scrollController.addListener(_scrollListener);  // Tambahkan listener untuk scroll
  }

  // Fungsi untuk mengambil feed pertama kali
  Future<void> _fetchFeed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final feed = await feedController.getFeed();
      setState(() {
        _feed = feed;
        _isLoading = false;
      });
    } on Exception catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mengambil feed baru saat scroll mencapai akhir
  Future<void> _fetchMoreFeed() async {
    if (_isLoadingMore) return;  // Jangan memuat lebih jika masih loading

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newFeed = await feedController.getFeedNew();
      if (newFeed.isNotEmpty) {
        setState(() {
          _feed.addAll(newFeed);  // Tambahkan feed baru ke dalam list
        });
      }
    } on Exception catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // Listener untuk mendeteksi ketika scroll mencapai akhir
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      _fetchMoreFeed();  // Panggil fetchMoreFeed saat scroll mencapai akhir
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();  // Jangan lupa untuk dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: _fetchFeed,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              controller: _scrollController,  // Gunakan ScrollController
              slivers: [
                const SliverAppBar(
                  floating: true,
                  snap: true, // Menyembunyikan appbar saat scroll ke bawah, menampilkannya saat scroll ke atas
                  expandedHeight: 15.0, // Tinggi appbar saat diperluas
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text('SkyCloud'),
                  ),
                ),
                SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final feed = _feed[index];
                  final post = feed['post'];
                  final reason = feed['reason'];
                  final author = post['author'];
                  final desc = post['record']['text'];
                  final embed = post['embed'];
                  String? thumbUrl;
                  String? fullUrl;
                  if (embed != null &&
                      embed['images'] != null &&
                      embed['images'].isNotEmpty) {
                    thumbUrl = embed['images'][0]['thumb'];
                    fullUrl = embed['images'][0]['fullsize'];
                  }

                  bool isVideo = embed != null && embed['playlist'] != null && embed['playlist'].endsWith('.m3u8');

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reason != null
                            ? Padding(
                                padding: const EdgeInsets.only(left: 50, bottom: 5),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.repeat,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Repost by ${reason['by']['displayName']}",
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/profile',
                                    arguments: author['did']);
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: CachedNetworkImageProvider( author['avatar']),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(author['displayName'],
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 5),
                                    Text(author['handle'].length > 10 ? author['handle'].substring(0, 10) + '...' : author['handle'],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            )),
                                    const SizedBox()
                                  ],
                                ),
                                desc != null ? Text(desc) : Container(),
                                const SizedBox(
                                  height: 10,
                                ),
                                isVideo
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          child: VideoPlayers(
                                          url: embed['playlist'],
                                          width: 400,
                                          height: 200,
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
                                            )
                                          )
                                        : Container(),
                                        const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.favorite_outline,
                                                ),
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
                                                icon: const Icon(
                                                  Icons.share_outlined,
                                                ),
                                                onPressed: () {},
                                              ),
                                              Text(
                                                  post['repostCount'] >= 10000000
                                                      ? '${(post['repostCount'] / 10000000).toStringAsFixed(1)}M'
                                                      : post['repostCount'] >= 1000
                                                          ? '${(post['repostCount'] / 1000).toStringAsFixed(0)}k'
                                                          : post['repostCount'].toString()),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.comment_outlined,
                                                ),
                                                onPressed: () {},
                                              ),
                                              Text(post['replyCount'] >= 10000000
                                                      ? '${(post['replyCount'] / 10000000).toStringAsFixed(1)}M'
                                                      : post['replyCount'] >= 1000
                                                          ? '${(post['replyCount'] / 1000).toStringAsFixed(0)}k'
                                                          : post['replyCount'].toString()),
                                            ],
                                          )
                                        ],
                                      ),
                              ],
                            )),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                childCount: _feed.length,
              ),
            ),
              ],
            ),
      )
    );
  }
}
