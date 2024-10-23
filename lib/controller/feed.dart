import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/getfeed.dart';
import '../services/url.dart';

class Feed {
  final Getfeed feedController = Getfeed();
  final UrlService urlController = UrlService();
  final String k = 'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot';
  String? _cursor; 

  Future<List<dynamic>> getFeed() async {
    final Uri url = Uri.parse('${urlController.url}${feedController.feed}?feed=$k');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> feed = jsonDecode(response.body);
      _cursor = feed['cursor'];
      return feed['feed'];
    } else {
      throw Exception('getFeed: Failed to fetch feed');
    }
  }

  // Fungsi untuk mengambil feed selanjutnya menggunakan cursor
  Future<List<dynamic>> getFeedNew() async {
    if (_cursor == null) {
      return [];
    }
    
    final Uri url = Uri.parse('${urlController.url}${feedController.feed}?feed=$k&cursor=$_cursor');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> feed = jsonDecode(response.body);
      _cursor = feed['cursor'];  // Perbarui cursor dengan nilai yang baru
      return feed['feed'];
    } else {
      throw Exception('getFeedNew: Failed to fetch new feed');
    }
  }
}

