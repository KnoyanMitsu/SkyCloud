// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:skycloud/controller/profile.dart';
import 'package:skycloud/views/detailpost.dart';

import '../widget/fullimage.dart';
import '../widget/media.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final Feed _profileController = Feed();
  Map<String, dynamic>? _profileData;
  List<dynamic> _feedData = [];
  bool _isDescriptionExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String actorId = ModalRoute.of(context)!.settings.arguments as String;
    _fetchProfile(actorId);
  }

  Future<void> _fetchProfile(String did) async {
    try {
      final profile = await _profileController.getProfile(did);
      final feed = await _profileController.getFeed(did);
      setState(() {
        _profileData = profile;
        _feedData = feed;
      });
    } on Exception catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileData;

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
                      ? CachedNetworkImage(imageUrl: profile!['banner'], fit: BoxFit.fitWidth)
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
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      profile?['handle'] != null ? '@${profile!['handle']}' : 'No Handle',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text("Followers: "),
                        Text(
                          profile?['followersCount'].toString() ?? '0',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 40),
                        const Text("Following: "),
                        Text(
                          profile?["followsCount"].toString() ?? "0",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    _buildDescription(profile?['description'] ?? ""),
                    const Divider(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final feedItem = _feedData[index];
                  final post = feedItem['post'];
                  final reason = feedItem['reason'];
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

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(uri: post['uri']),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reason != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 50, bottom: 5),
                              child: Row(
                                children: [
                                  const Icon(Icons.repeat, size: 16),
                                  const SizedBox(width: 5),
                                  Text("Repost by ${reason['by']['displayName']}"),
                                ],
                              ),
                            ),
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
                                        Text(
                                          author['handle'].length > 10 ? '${author['handle'].substring(0, 10)}...' : author['handle'],
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    if (description != null) Text(description),
                                    const SizedBox(height: 10),
                                    if (isVideo)
                                      ClipRRect(
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
                                    else if (thumbnailUrl != null)
                                      ClipRRect(
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
                                            width: 430,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildIconText(Icons.favorite_outline, post['likeCount']),
                                        _buildIconText(Icons.share_outlined, post['repostCount']),
                                        _buildIconText(Icons.comment_outlined, post['replyCount']),
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
                },
                childCount: _feedData.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(String description) {
    const maxLength = 100;
    final end = description.length > maxLength ? maxLength : description.length;

    return Column(
      children: [
        Text(
          _isDescriptionExpanded ? description : '${description.substring(0, end)}...',
          maxLines: _isDescriptionExpanded ? null : 2,
          style: const TextStyle(fontSize: 16),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isDescriptionExpanded = !_isDescriptionExpanded;
            });
          },
          child: Text(
            _isDescriptionExpanded ? 'Show Less' : 'See More',
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildIconText(IconData icon, int count) {
    return Row(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {},
        ),
        Text(
          count >= 10000000
              ? '${(count / 10000000).toStringAsFixed(1)}M'
              : count >= 1000
                  ? '${(count / 1000).toStringAsFixed(0)}k'
                  : count.toString(),
        ),
      ],
    );
  }
}

