// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class FullImagePage extends StatefulWidget {
  final String imageUrl;

  const FullImagePage({super.key, required this.imageUrl});

  @override
  FullImagePageState createState() => FullImagePageState();
}

class FullImagePageState extends State<FullImagePage> {
  bool _isLoading = false;
  Uint8List? _imageBytes;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final http.Response response = await http.get(Uri.parse(widget.imageUrl));
      final Uint8List bytes = response.bodyBytes;

      setState(() {
        _imageBytes = bytes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _saveImageToDevice() async {
    try {
      const String appName = 'SkyCloud';
      if (Platform.isAndroid) {
        const String picturesDirectory = '/storage/emulated/0/Pictures/$appName';
        await Directory(picturesDirectory).create(recursive: true);
        final String fileName = widget.imageUrl.split('/').last;
        final File imageFile = File('$picturesDirectory/$fileName');
        await imageFile.writeAsBytes(_imageBytes!);
        var location = picturesDirectory;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to: $location')),
        );
      } else {
        final directory = await getDownloadsDirectory();
        final String picturesDirectory = '${directory!.path}/Pictures/$appName';
        await Directory(picturesDirectory).create(recursive: true);
        final String fileName = widget.imageUrl.split('/').last;
        final File imageFile = File('$picturesDirectory/$fileName');
        await imageFile.writeAsBytes(_imageBytes!);
        var location = picturesDirectory;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to: $location')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin plugin = DeviceInfoPlugin();
      AndroidDeviceInfo android = await plugin.androidInfo;
      if (android.version.sdkInt < 33) {
        if (await Permission.storage.request().isGranted) {
          setState(() {
            _saveImageToDevice();
          });
        } else if (await Permission.storage.request().isPermanentlyDenied) {
          await openAppSettings();
        } else if (await Permission.audio.request().isDenied) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission denied')),
            );
          });
        }
      } else {
        if (await Permission.photos.request().isGranted) {
          setState(() {
            _saveImageToDevice();
          });
        } else if (await Permission.photos.request().isPermanentlyDenied) {
          await openAppSettings();
        } else if (await Permission.photos.request().isDenied) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission denied')),
            );
          });
        }
      }
    } else {
      _saveImageToDevice();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.download),
              onPressed: _isLoading ? null : _requestPermission,),
        ],
      ),
      body: errorText != null
          ? buildErrorWidget()
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _imageBytes != null
                  ? Center(
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : const Center(child: Text('Failed to load image')),
    );
  }

  Widget buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            errorText!,
            style: const TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                errorText = null;
              });
              _loadImage();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

