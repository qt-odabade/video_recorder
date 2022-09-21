import 'package:flutter_video_info/flutter_video_info.dart';

class Utils {
  static final videoInfo = FlutterVideoInfo();

  static void getVideoMetaData(String path) async {
    var info = await videoInfo.getVideoInfo(path);
    // print(info?.author);
    print(info?.date);
    print("${(info?.duration ?? 0) / 1000} secs");
    print("${(info?.filesize ?? 0) / 1024 / 1024} MB");
    // print(info?.framerate);
    print("${info?.height} x ${info?.width}");
    // print(info?.location);
    print(info?.mimetype);
    print(info?.orientation);
    print(info?.path);
    print(info?.title);
  }
}
