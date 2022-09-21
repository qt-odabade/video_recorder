import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_recorder/utils.dart';
import 'package:video_recorder/videos_list.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget>
    with WidgetsBindingObserver {
  CameraController? controller;

  List<CameraDescription> _cameras = [];
  CameraDescription? _currentSelectedCamera;
  Timer? _videoTimer;
  Uint8List? _lastVideoThumbnail;

  int minutes = 0, seconds = 0;
  final ValueNotifier<int> _secondsOfVideoRecorded = ValueNotifier<int>(0);

  // XFile? latestVideoFile;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getCameras();

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    _videoTimer?.cancel();
    _secondsOfVideoRecorded.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !(controller?.value.isInitialized ?? false)) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(controller!.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller == null
          ? const Center(child: CircularProgressIndicator())
          : _cameras.isEmpty
              ? const Center(
                  child: Text('No camera(s) found\nPlease try again later'))
              : OrientationBuilder(
                  builder: (context, orientation) {
                    return orientation == Orientation.portrait
                        ? Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.9,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    SizedBox.expand(
                                        child: CameraPreview(controller!)),
                                    if (controller?.value.isRecordingVideo ??
                                        false)
                                      Positioned(
                                        top: 50.0,
                                        child: ValueListenableBuilder<int>(
                                          valueListenable:
                                              _secondsOfVideoRecorded,
                                          builder: (context, value, child) {
                                            minutes = value ~/ 60;
                                            seconds = value % 60;

                                            return Chip(
                                              avatar: const Icon(
                                                Icons.circle_rounded,
                                                color: Colors.red,
                                              ),
                                              label: Text(
                                                  "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}"),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    controller?.value.isRecordingVideo ?? false
                                        // Pause and Resume
                                        ? IconButton(
                                            icon: controller?.value
                                                        .isRecordingPaused ??
                                                    false
                                                ? const Icon(Icons.play_arrow)
                                                : const Icon(Icons.pause),
                                            // color: Colors.white,
                                            onPressed: (controller?.value
                                                            .isInitialized ??
                                                        false) &&
                                                    (controller?.value
                                                            .isRecordingVideo ??
                                                        false)
                                                ? controller?.value
                                                            .isRecordingPaused ??
                                                        false
                                                    ? resumeRecording
                                                    : pauseRecording
                                                : null,
                                          )
                                        // Switch Camera
                                        : IconButton(
                                            onPressed: _switchCamera,
                                            icon: const Icon(
                                              Icons.restart_alt_rounded,
                                              // color: Colors.white,
                                            ),
                                          ),
                                    IconButton(
                                      onPressed:
                                          (controller?.value.isInitialized ??
                                                      false) &&
                                                  (controller?.value
                                                          .isRecordingVideo ??
                                                      false)
                                              ? stopRecording
                                              : startRecording,
                                      enableFeedback: true,
                                      iconSize: 60.0,
                                      icon: (controller?.value.isInitialized ??
                                                  false) &&
                                              (controller?.value
                                                      .isRecordingVideo ??
                                                  false)
                                          ? const Icon(
                                              Icons.stop_circle_outlined,
                                              color: Colors.red,
                                            )
                                          : const Icon(
                                              Icons.camera_rounded,
                                              // color: Colors.blue,
                                            ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const VideosList()),
                                        );
                                      },
                                      icon: _lastVideoThumbnail != null
                                          ? Image.memory(
                                              _lastVideoThumbnail!,
                                              width: 35.0,
                                              fit: BoxFit.fitWidth,
                                            )
                                          : const Icon(
                                              Icons.photo_library,
                                              // color: Colors.white,
                                            ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    SizedBox.expand(
                                        child: CameraPreview(controller!)),
                                    if (controller?.value.isRecordingVideo ??
                                        false)
                                      Positioned(
                                        top: 50.0,
                                        child: ValueListenableBuilder<int>(
                                          valueListenable:
                                              _secondsOfVideoRecorded,
                                          builder: (context, value, child) {
                                            minutes = value ~/ 60;
                                            seconds = value % 60;

                                            return Chip(
                                              avatar: const Icon(
                                                Icons.circle_rounded,
                                                color: Colors.red,
                                              ),
                                              label: Text(
                                                  "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}"),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const VideosList()),
                                        );
                                      },
                                      icon: _lastVideoThumbnail != null
                                          ? Image.memory(
                                              _lastVideoThumbnail!,
                                              width: 35.0,
                                              fit: BoxFit.fitWidth,
                                            )
                                          : const Icon(
                                              Icons.photo_library,
                                              // color: Colors.white,
                                            ),
                                    ),
                                    IconButton(
                                      onPressed:
                                          (controller?.value.isInitialized ??
                                                      false) &&
                                                  (controller?.value
                                                          .isRecordingVideo ??
                                                      false)
                                              ? stopRecording
                                              : startRecording,
                                      enableFeedback: true,
                                      iconSize: 60.0,
                                      icon: (controller?.value.isInitialized ??
                                                  false) &&
                                              (controller?.value
                                                      .isRecordingVideo ??
                                                  false)
                                          ? const Icon(
                                              Icons.stop_circle_outlined,
                                              color: Colors.red,
                                            )
                                          : const Icon(
                                              Icons.camera_rounded,
                                              // color: Colors.blue,
                                            ),
                                    ),
                                    controller?.value.isRecordingVideo ?? false
                                        // Pause and Resume
                                        ? IconButton(
                                            icon: controller?.value
                                                        .isRecordingPaused ??
                                                    false
                                                ? const Icon(Icons.play_arrow)
                                                : const Icon(Icons.pause),
                                            // color: Colors.white,
                                            onPressed: (controller?.value
                                                            .isInitialized ??
                                                        false) &&
                                                    (controller?.value
                                                            .isRecordingVideo ??
                                                        false)
                                                ? controller?.value
                                                            .isRecordingPaused ??
                                                        false
                                                    ? resumeRecording
                                                    : pauseRecording
                                                : null,
                                          )
                                        // Switch Camera
                                        : IconButton(
                                            onPressed: _switchCamera,
                                            icon: const Icon(
                                              Icons.restart_alt_rounded,
                                              // color: Colors.white,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          );
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void showSnackBar({required String message}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> getCameras() async {
    try {
      _cameras = await availableCameras();

      _switchCamera();
    } on CameraException {
      showSnackBar(message: 'error reading cameras');

      _cameras = [];
    }
  }

  Future<void> _switchCamera() async {
    if (controller?.value.isRecordingVideo ?? false) {
      return;
    }

    if (_cameras.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        showSnackBar(message: 'No camera found.');
      });
    } else {
      switch (_currentSelectedCamera?.lensDirection) {
        case null:
          _currentSelectedCamera = _cameras.first;
          break;

        case CameraLensDirection.front:
          _currentSelectedCamera = _cameras.firstWhere(
              (cam) => cam.lensDirection == CameraLensDirection.back);
          break;
        case CameraLensDirection.back:
          _currentSelectedCamera = _cameras.firstWhere(
              (cam) => cam.lensDirection == CameraLensDirection.front);
          break;
        case CameraLensDirection.external:
          _currentSelectedCamera = _cameras.firstWhere(
              (cam) => cam.lensDirection == CameraLensDirection.back);
          break;
      }

      await onNewCameraSelected(_currentSelectedCamera!);
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;

    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController =
        CameraController(cameraDescription, ResolutionPreset.max);

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showSnackBar(
            message: 'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      showSnackBar(message: 'Error: ${e.description ?? e.code}');
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> startRecording() async {
    try {
      controller?.startVideoRecording().then((value) {
        setState;
        _videoTimer = Timer.periodic(
          const Duration(seconds: 1),
          (timer) {
            _secondsOfVideoRecorded.value++;
          },
        );
      });
    } on CameraException catch (e) {
      showSnackBar(message: e.description ?? e.code);
    }
  }

  Future<void> resumeRecording() async {
    try {
      controller?.resumeVideoRecording().then((value) {
        setState(() {});

        _videoTimer = Timer.periodic(
          const Duration(seconds: 1),
          (timer) {
            _secondsOfVideoRecorded.value++;
          },
        );

        showSnackBar(message: 'Video recording resumed');
      });
    } on CameraException catch (e) {
      showSnackBar(message: e.description ?? e.code);
    }
  }

  Future<void> pauseRecording() async {
    try {
      controller?.pauseVideoRecording().then((value) {
        setState(() {});
        _videoTimer?.cancel();
        showSnackBar(message: 'Video recording paused');
      });
    } on CameraException catch (e) {
      showSnackBar(message: e.description ?? e.code);
    }
  }

  Future<void> stopRecording() async {
    try {
      controller?.stopVideoRecording().then((XFile? file) async {
        if (mounted) {
          setState(() {});
        }

        _videoTimer?.cancel();
        _secondsOfVideoRecorded.value = 0;

        if (file != null) {
          // latestVideoFile = file;

          // print(file.mimeType);
          // print(file.name);
          // print(file.path);
          // print(await file.length());

          // print(file.mimeType);

          final directory = await getApplicationDocumentsDirectory();
          String newPath = "${directory.path}/${file.name}";

          await file.saveTo(newPath);

          Utils.getVideoMetaData(newPath);
          _lastVideoThumbnail = await vt.VideoThumbnail.thumbnailData(
              video: newPath, quality: 50, imageFormat: vt.ImageFormat.JPEG);

          // Update the View to show new thumbnail
          setState(() {});

          showSnackBar(message: 'Video ${file.name} saved');
        }
      });
    } on CameraException catch (e) {
      showSnackBar(message: e.description ?? e.code);
    }
  }
}
