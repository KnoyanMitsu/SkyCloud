import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/feedprofile.dart';
import '../services/getprofile.dart';
import '../services/url.dart';

class Feed {
  final UrlService urlService = UrlService();
  final GetProfileService profileService = GetProfileService();
  final FeedProfileService feedService = FeedProfileService();

  Future<Map<String, dynamic>> getProfile(String did) async {
    final Uri url = Uri.parse('${urlService.url}${profileService.profile}?actor=$did');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> profile = jsonDecode(response.body);
      return profile;
    } else {
      throw Exception('Failed to fetch profile');
    }
  }
      Future<List<dynamic>> getFeed(String did) async {
    final Uri url = Uri.parse('${urlService.url}${feedService.profile}?actor=$did');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> feed = jsonDecode(response.body);
      return feed['feed'];
    } else {
      throw Exception('Failed to fetch profile');
    }
  }
}
