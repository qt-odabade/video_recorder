import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_recorder/model/video_file.dart';
import 'package:video_recorder/service/database.dart';
import 'package:video_recorder/view/widget/video_player.dart';

class VideosList extends StatefulWidget {
  const VideosList({super.key});

  @override
  State<VideosList> createState() => _VideosListState();
}

class _VideosListState extends State<VideosList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<VideoFile>>(
        future: getFiles(),
        builder: (context, snapshot) {
          print(snapshot.connectionState);

          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(child: CircularProgressIndicator());

            case ConnectionState.done:
              if (snapshot.data?.isEmpty ?? true) {
                return const Center(
                  child: Text('No recordings found'),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.file(
                      File(snapshot.data![index].thumbnailLocation ?? ''),
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.file_present_rounded);
                      },
                      width: 40.0,
                      height: 40.0,
                      fit: BoxFit.cover,
                    ),
                    title: Text(snapshot.data![index].title),
                    subtitle: snapshot.data![index].filesize != null &&
                            snapshot.data![index].duration != null
                        ? Text(
                            "(${snapshot.data![index].duration! ~/ 1000}secs) ${(snapshot.data![index].filesize! / 1024 / 1024).toStringAsFixed(2)} MB")
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerApp(
                            file: File(snapshot.data![index].videoLocation),
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

  Future<List<VideoFile>> getFiles() async {
    return Database.instance.files;

    // final directory = await getApplicationDocumentsDirectory();

    // final videoDirectory = Directory('${directory.path}/Videos');
    // files = videoDirectory.listSync().whereType<File>().toList();

    // print(files);

    // final thumbnailDirectory = Directory('${directory.path}/Thumbnails');
    // thumbnails = thumbnailDirectory.listSync().whereType<File>().toList();

    // print(thumbnails);

    // return files;
  }
}
