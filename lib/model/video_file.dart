import 'package:objectbox/objectbox.dart';

@Entity()
class VideoFile {
  int id;
  String title;
  String videoLocation;
  String? thumbnailLocation;

  /// String
  String? mimetype;

  /// String
  String? date;

  /// Int
  int? width;

  /// Int
  int? height;

  /// [Android] API level 17, (0,90,180,270)
  /// (0 - LandscapeRight)
  /// (90 - Portrait)
  /// (180 - LandscapeLeft)
  /// (270 - portraitUpsideDown)
  int? orientation;

  /// Bytes
  int? filesize;

  /// Millisecond
  double? duration;

  VideoFile({
    this.id = 0,
    required this.title,
    required this.videoLocation,
    required this.thumbnailLocation,
    this.date,
    this.duration,
    this.filesize,
    this.height,
    this.mimetype,
    this.orientation,
    this.width,
  });
}
