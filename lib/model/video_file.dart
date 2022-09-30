import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class VideoFile {
  int id;
  String name;
  String videoLocation;
  String thumbnailLocation;
  VideoData? videoData;

  VideoFile({
    this.id = 0,
    required this.name,
    required this.videoLocation,
    required this.thumbnailLocation,
    this.videoData,
  });
}
