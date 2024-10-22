import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';// Tambahkan ini
import 'package:fvp/fvp.dart' as fvp;
import 'package:skycloud/views/feed.dart';
import 'package:skycloud/views/profile.dart';

import 'views/search.dart'; // Import file search.dart

void main() {

    fvp.registerWith(options: {
    'video.decoders': ['FFmpeg'],
    'platform': [
      'android','linux'],
    'lowLatency': 1,
     'player': {
        'buffer': '2000+60000',
        'demux.buffer.protocols': 'file,http,https', // if data is not enough, cache 2s, max is 60s
        'demux.buffer.ranges': '8', // or other integer value as string
      } // optional for network streams
    });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Mode tema default

  void toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode, // Gunakan variabel _themeMode yang dapat berubah
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(toggleTheme: toggleTheme), // Pass toggleTheme ke HomePage
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

// Halaman Utama (Home Page)
class HomePage extends StatefulWidget {
  final Function(ThemeMode) toggleTheme; // Fungsi untuk mengganti tema

  const HomePage({super.key, required this.toggleTheme});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Untuk menyimpan indeks halaman yang dipilih

  // Daftar halaman yang bisa dinavigasi
  final List<Widget> _pages = [
    const FeedPage(),
    SearchPage(),
  ];



  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
        body: _pages[_selectedIndex], // Menampilkan halaman berdasarkan indeks yang dipilih
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedIndex: _selectedIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
          ], // Mengubah halaman saat item di-tap
        ),
      ),
    );
  }
}

