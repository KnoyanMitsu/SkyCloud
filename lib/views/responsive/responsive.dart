import 'package:flutter/material.dart';
import 'package:skycloud/views/responsive/desktop.dart';
import 'package:skycloud/views/responsive/mobile.dart';
import 'package:skycloud/views/responsive/tablet.dart';

class Responsive extends StatelessWidget {
  const Responsive({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        if(constraints.maxWidth > 1200){
          return const Desktop();
        }
        else if (constraints.maxWidth > 800){
          return const Tablet();
        
        }
        
        else{
          return const Mobile();
        }
      },
    );
  }
}