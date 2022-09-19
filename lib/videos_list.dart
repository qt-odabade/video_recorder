import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
                  title: Text(files![index].toString()),
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
