import 'package:video_recorder/model/video_file.dart';

import '../objectbox.g.dart';

class Database {
  late Box<VideoFile> _box;

  Future<void> init() async {
    final store = await openStore();
    _box = store.box<VideoFile>();
  }

  List<VideoFile> get files => _box.getAll();

  Future<void> saveVideoFile({required VideoFile videoFile}) async {
    await _box.putAsync(videoFile);
  }
}
