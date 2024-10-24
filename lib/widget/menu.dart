import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      
      child: ListView(
        padding: EdgeInsets.zero,
        children:  [
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.surfaceTint, BlendMode.srcIn),
                image: Image.asset(
                  'assets/images/Frame 1.png',
                ).image
              )
            ),
            child: const Align(
              alignment: Alignment.topRight,
              child: Text('SkyCloud', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            ),
          ),
          const ListTile(
            title: Text('No Item Here. Try back later :)'),
          ),
        ],
      ),
    );
  }
}