import 'package:flutter/material.dart';
import 'package:skycloud/views/feed.dart';
import 'package:skycloud/views/search.dart';
import 'package:skycloud/widget/menu.dart';

class Tablet extends StatefulWidget {
  const Tablet({super.key});

  @override
  State<Tablet> createState() => _TabletState();
}

class _TabletState extends State<Tablet> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FeedPage(),
    const SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      body: Row(
        children: [
          const Expanded(
            flex: 0,
            child: Menu(),
          ),
          Expanded(
            flex: 3,
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          if (index >= 0 && index < _pages.length) {
            setState(() {
              _selectedIndex = index;
            });
          }
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
        ],
      ),
    );
  }
}

