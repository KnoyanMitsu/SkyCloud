import 'package:flutter/material.dart';
import 'package:skycloud/controller/feed.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
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
      print('Error: $error');
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
      print('Error: $error');
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
                      if (index == _feed.length && _isLoadingMore) {
                        return const Center(child: CircularProgressIndicator());  // Tampilkan loading saat mengambil data baru
                      }
                      final feed = _feed[index];
                      final post = feed['post'];
                      final author = post['author'];
                      final desc = post['record']['text'];
                      final embed = post['embed'];
                      String? thumbUrl;
                      if (embed != null &&
                          embed['images'] != null &&
                          embed['images'].isNotEmpty) {
                        thumbUrl = embed['images'][0]['thumb'];
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/profile',
                                        arguments: author['did']);
                                  },
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: author['avatar'] != null
                                        ? NetworkImage(author['avatar'])
                                        : null,
                                    child: author['avatar'] == null
                                        ? const Icon(Icons.person) // Icon jika avatar kosong
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            author['displayName'] ?? 'Unknown',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 5),
                                        ],
                                      ),
                                      desc != null ? Text(desc) : Container(),
                                      const SizedBox(height: 10),
                                      thumbUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                thumbUrl,
                                                height: 430,
                                                width: 430,
                                                fit: BoxFit.cover,
                                              ),
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
                                              Text(post['likeCount'].toString()),
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
                                              Text(post['repostCount']
                                                  .toString()),
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
                                              Text(post['replyCount'].toString()),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                          ],
                        ),
                      );
                    },
                    childCount: _feed.length + (_isLoadingMore ? 1 : 0),  // Tambahkan satu child lagi jika loading data baru
                  ),
                ),
              ],
            ),
      )
    );
  }
}
