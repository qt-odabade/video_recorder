import 'package:flutter/material.dart';
import 'package:video_recorder/camera_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const VideoRecorder());
}

class VideoRecorder extends StatelessWidget {
  const VideoRecorder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraWidget(),
    );
  }
}
