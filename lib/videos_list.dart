import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_recorder/video_player.dart';

class VideosList extends StatefulWidget {
  const VideosList({super.key});

  @override
  State<VideosList> createState() => _VideosListState();
}

class _VideosListState extends State<VideosList> {
  List<File> files = [];
  List<File> thumbnails = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<File>>(
        future: getFiles(),
        builder: (context, snapshot) {
          print(snapshot.connectionState);

          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(child: CircularProgressIndicator());

            case ConnectionState.done:
              if (files.isEmpty) {
                return const Center(
                  child: Text('No recordings found'),
                );
              }

              return ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  var fileName =
                      files[index].path.split('/').last.split('.').first;

                  return ListTile(
                    leading: Image.file(
                      thumbnails.firstWhere(
                        (element) => element.path.endsWith("$fileName.jpg"),
                        orElse: () => File(''),
                      ),
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.file_present_rounded);
                      },
                      width: 40.0,
                      height: 40.0,
                      fit: BoxFit.cover,
                    ),
                    title: Text(files[index].path.split('/').last),
                    subtitle: Text(
                        "${(files[index].statSync().size / 1024 / 1024).toStringAsFixed(2)} MB"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerApp(
                            file: files[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
          }
        },
      ),
    );
  }

  Future<List<File>> getFiles() async {
    final directory = await getApplicationDocumentsDirectory();

    final videoDirectory = Directory('${directory.path}/Videos');
    files = videoDirectory.listSync().whereType<File>().toList();

    print(files);

    final thumbnailDirectory = Directory('${directory.path}/Thumbnails');
    thumbnails = thumbnailDirectory.listSync().whereType<File>().toList();

    print(thumbnails);

    return files;
  }
}
