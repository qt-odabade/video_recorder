import 'package:flutter/material.dart';
import 'package:video_recorder/service/database.dart';
import 'package:video_recorder/view/widget/camera_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Database.instance.init();

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
