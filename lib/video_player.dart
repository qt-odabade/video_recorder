import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerApp extends StatefulWidget {
  final File file;
  const VideoPlayerApp({super.key, required this.file});

  @override
  State<VideoPlayerApp> createState() => _VideoPlayerAppState();
}

class _VideoPlayerAppState extends State<VideoPlayerApp> {
  late VideoPlayerController _controller;

  String? errorMessage;

  @override
  void initState() {
    _controller = VideoPlayerController.file(widget.file);
    _controller.addListener(() {
      if (_controller.value.hasError) {
        errorMessage = 'Some error occured';
      }

      // React on play and pause of video, to control rendering of play button
      setState(() {});
    });

    // setState to render first frame of video
    _controller.initialize().then((value) => setState);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 50),
                        reverseDuration: const Duration(milliseconds: 200),
                        child: _controller.value.isPlaying
                            ? const SizedBox.shrink()
                            : Container(
                                color: Colors.black12,
                                child: const Center(
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 80.0,
                                  ),
                                ),
                              ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        },
                      ),
                    ],
                  ),
                ),
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
