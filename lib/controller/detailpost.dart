import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:skycloud/services/detailpost.dart';

import '../services/url.dart';


class Detailpost {
  final UrlService urlController = UrlService();
  final Getdetailpost detailpostController = Getdetailpost();

  Future<Map<String, dynamic>> getDetailPost(String uri) async {
    final Uri url = Uri.parse('${urlController.url}${detailpostController.detail}?uri=$uri');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> detailpost = jsonDecode(response.body);
      return detailpost['thread']['post'];
    } else {
      throw Exception('Failed to fetch detailpost');
    }
  }
}