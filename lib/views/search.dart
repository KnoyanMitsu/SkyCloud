import 'package:flutter/material.dart';

import '../controller/search.dart';  // Import SearchController

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final search _searchController = search();
  List<dynamic> _results = [];  // Menyimpan hasil pencarian
  bool _isLoading = false;      // Indikator loading

  // Fungsi untuk memanggil controller dan melakukan pencarian
  void _searchActors(String name) async {
    setState(() {
      _isLoading = true;  // Menampilkan loading saat menunggu hasil
    });

    try {
      final results = await _searchController.searchActors(name);
      setState(() {
        _results = results;
      });
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;  // Sembunyikan loading setelah selesai
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(borderRadius: 
              BorderRadius.circular(100.0),),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _searchActors(value);  // Melakukan pencarian saat submit
                }
              },
            ),
            SizedBox(
              height: 20,
            ),
            // Tampilkan indikator loading
            if (_isLoading)
              CircularProgressIndicator(),
            // Tampilkan hasil pencarian
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final actor = _results[index];
                  return ListTile(
                    leading: 
                    actor['avatar'] == null ? 
                    CircleAvatar() :
                    CircleAvatar(backgroundImage: NetworkImage(actor['avatar']),),
                    title: Text(actor['displayName']), 
                    subtitle: Text(actor['handle']),
                    onTap: (){
                      Navigator.pushNamed(context, '/profile', arguments: actor['did']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
