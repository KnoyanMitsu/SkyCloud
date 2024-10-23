import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/getsearch.dart';
import '../services/url.dart';

class Search {
  final SearchService searchController = SearchService();
  final UrlService urlController = UrlService();
  
  Future<List<dynamic>> searchActors(String name) async {
    final Uri url = Uri.parse('${urlController.url}${searchController.search}?q=$name');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parsing dari JSON
      Map<String, dynamic> data = jsonDecode(response.body);
      return data['actors'];  // Ambil daftar actors dari respons JSON
    } else {
      throw Exception('Failed to fetch actors');
    }
  }
}
