import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:skycloud/views/feed.dart';
import 'package:skycloud/views/profile.dart';

import 'views/search.dart'; // Import file search.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
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
        '/search': (context) => SearchPage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}

// Halaman Utama (Home Page)
class HomePage extends StatefulWidget {
  final Function(ThemeMode) toggleTheme; // Fungsi untuk mengganti tema

  HomePage({required this.toggleTheme});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Untuk menyimpan indeks halaman yang dipilih

  // Daftar halaman yang bisa dinavigasi
  final List<Widget> _pages = [
    FeedPage(),
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

