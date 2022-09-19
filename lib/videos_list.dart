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
  List<File>? files = [];

  @override
  void initState() {
    getFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: files != null
          ? ListView.builder(
              itemCount: files?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(files![index].path.split('/').last),
                  subtitle: Text(
                      "${(files![index].statSync().size / 1024 / 1024).toStringAsFixed(2)} MB"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerApp(
                          file: files![index],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> getFiles() async {
    files = await getApplicationDocumentsDirectory()
        .then((value) => value.listSync().whereType<File>().toList());

    setState(() {});

    print(files);
  }
}
