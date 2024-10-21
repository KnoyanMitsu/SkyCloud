import 'package:flutter/material.dart';
import 'package:skycloud/controller/profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Feed _profileController = Feed();
  Map<String, dynamic>? _profile;
  List<dynamic> _feed = [];
  bool _isLoading = true;
  bool _isDescriptionExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String actorId = ModalRoute.of(context)!.settings.arguments as String;
    _fetchProfile(actorId);
  }

  Future<void> _fetchProfile(String did) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _profileController.getProfile(did);
      final feed = await _profileController.getFeed(did);
      setState(() {
        _profile = profile;
        _feed = feed;
        _isLoading = false;
      });
    } on Exception catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                profile != null
                    ? Image.network(profile['banner'], fit: BoxFit.fitWidth)
                    : Container(
                        color: Colors.grey, width: double.infinity, height: 200,),
 
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                  [CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          profile?['avatar'] ?? ''),
                    ),
                  Text(
                    profile?['displayName'] ?? 'No Name',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  profile?['handle'] != null ?
                  Text(
                    '@' + profile?['handle'],
                    style: const TextStyle(color: Colors.grey),
                  ) : Text(
                    'No Handle',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                      )
                    ],
                  ),
                  _buildDescription(profile?['description'] ?? ""),
                                                  Divider(),
                  const SizedBox(height: 20),
                

                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
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
                              Navigator.pushNamed(context, '/profile', arguments: author['did']);
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(author['avatar']),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                   Text(author['displayName'],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 5,),
                              //  Text('@'+author['handle'],
                              //     style: const TextStyle(
                              //         fontSize: 14,
                              //         color: Colors.grey),
                              //   ),
                                ],
                              ),
                                                            desc != null ? Text(desc) : Container(),
                              const SizedBox(
                                height: 10,
                              ),
                              thumbUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        thumbUrl,
                                        height: 430,
                                        width: 430,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(),
                              const SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      Text(post['repostCount'].toString())
                                      ,
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      SizedBox(width: 30,),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.comment_outlined,
                                        ),
                                        onPressed: () {},
                                      ),
                                      Text(post['replyCount'].toString()),
                                      SizedBox(width: 30,),
                                    ],
                                  )
                                ],
                              ),
                              
                            ],
                          )),
                        
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
                );
              },
              childCount: _feed.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    final maxLength = 100;
    final end = description.length > maxLength ? maxLength : description.length;

    return Column(
      children: [
        Text(
          _isDescriptionExpanded
              ? description
              : description.substring(0, end) + '...', // Sesuaikan panjang karakter
          maxLines: _isDescriptionExpanded ? null : 2, // Sesuaikan jumlah baris
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
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

