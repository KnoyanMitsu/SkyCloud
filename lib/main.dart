  import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:skycloud/views/profile.dart';
import 'package:skycloud/views/responsive/responsive.dart';

  void main() {
    WidgetsFlutterBinding.ensureInitialized();
    fvp.registerWith(options: {
      'video.decoders': ['FFMpeg','MediaCodec'],
      'platform': ['android', 'linux'],
      'lowLatency': 1,
      'player': {
        'demux.buffer.protocols': 'file,http,https',
        'demux.buffer.ranges': '8',
      }
    });
    runApp(const MyApp());
  }

  class MyApp extends StatefulWidget {
    const MyApp({super.key});

    @override
    MyAppState createState() => MyAppState();
  }

  class MyAppState extends State<MyApp> {
    final ThemeMode _themeMode = ThemeMode.system;

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SkyBlue',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.dark,
        ),
        themeMode: _themeMode,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/profile': (context) => const ProfilePage(),
          '/detail': (context) => const ProfilePage(),
        },
      );
    }
  }

  class HomePage extends StatefulWidget {
    final Function(ThemeMode)? toggleTheme;

    const HomePage({super.key, this.toggleTheme});

    @override
    HomePageState createState() => HomePageState();
  }

  class HomePageState extends State<HomePage> {

    @override
    Widget build(BuildContext context) {
      return ColorfulSafeArea(
        color: Theme.of(context).colorScheme.surface,
        child: const Responsive()
      );
    }
  }

