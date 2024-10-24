import 'package:flutter/material.dart';
import 'package:skycloud/views/feed.dart';
import 'package:skycloud/views/search.dart';
import 'package:skycloud/widget/menu.dart';



class Mobile extends StatefulWidget {
  const Mobile({super.key});

  @override
  State<Mobile> createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
      const FeedPage(),
      const SearchPage(),
    ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        drawer: const Menu(),
        body: _pages[_selectedIndex],
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