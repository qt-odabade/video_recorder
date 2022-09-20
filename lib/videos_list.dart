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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<File>>(
        future: getFiles(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.file_present_rounded),
                  title: Text(snapshot.data![index].path.split('/').last),
                  subtitle: Text(
                      "${(snapshot.data![index].statSync().size / 1024 / 1024).toStringAsFixed(2)} MB"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerApp(
                          file: snapshot.data![index],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List<File>> getFiles() async {
    return await getApplicationDocumentsDirectory()
        .then((value) => value.listSync().whereType<File>().toList());
  }
}
