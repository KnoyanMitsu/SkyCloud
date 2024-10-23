// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:skycloud/controller/profile.dart';

import '../widget/fullimage.dart';
import '../widget/media.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final Feed _profileController = Feed();
  Map<String, dynamic>? _profile;
  List<dynamic> _feed = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String actorId = ModalRoute.of(context)!.settings.arguments as String;
    _fetchProfile(actorId);
  }

  Future<void> _fetchProfile(String did) async {
    setState(() {
    });
  
    try {
      final profile = await _profileController.getProfile(did);
      final feed = await _profileController.getFeed(did);
      setState(() {
        _profile = profile;
        _feed = feed;
      });
    } on Exception catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return ColorfulSafeArea(
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  profile?['banner'] != null
                      ? CachedNetworkImage(imageUrl: profile?['banner'], fit: BoxFit.fitWidth)
                      : Container(
                          color: Theme.of(context).colorScheme.surface,
                          width: double.infinity,
                          height: 100,
                        ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: CachedNetworkImageProvider(profile?['avatar'] ?? ''),
                    ),
                    Text(
                      profile?['displayName'] ?? 'No Name',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    profile?['handle'] != null
                        ? Text(
                            '@' + profile?['handle'],
                            style: const TextStyle(color: Colors.grey),
                          )
                        : const Text(
                            'No Handle',
                            style: TextStyle(color: Colors.grey),
                          ),
                  ],
                ),
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
                                backgroundImage: NetworkImage(author['avatar']),
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
                                          width: 430,
                                          height: 300,
                                          child: VideoPlayers(
                                          url: embed['playlist'],
                                          width: 500,
                                          height: 300,
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
                                          
                                            child: CachedNetworkImage(imageUrl: 
                                              thumbUrl,
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
      ),
    );
  }
}

