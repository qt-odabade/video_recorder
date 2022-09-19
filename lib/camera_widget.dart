import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

  XFile? latestVideoFile;

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
      body:
          // If no camera available, show error msg
          controller == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: CameraPreview(controller!),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: controller!.value.isInitialized &&
                                  controller!.value.isRecordingVideo
                              ? const Icon(Icons.stop)
                              : const Icon(Icons.videocam),
                          color: controller!.value.isInitialized &&
                                  controller!.value.isRecordingVideo
                              ? Colors.red
                              : Colors.blue,
                          onPressed: controller!.value.isInitialized &&
                                  controller!.value.isRecordingVideo
                              // Stop recording Video
                              ? () async {
                                  try {
                                    controller
                                        ?.stopVideoRecording()
                                        .then((XFile? file) {
                                      if (mounted) {
                                        setState(() {});
                                      }

                                      if (file != null) {
                                        showSnackBar(
                                            message:
                                                'Video recorded to ${file.path}');
                                        latestVideoFile = file;
                                        // _startVideoPlayer();
                                      }
                                    });
                                  } on CameraException catch (e) {
                                    showSnackBar(
                                        message: e.description ?? e.code);
                                  }
                                }
                              // Start recording
                              : () async {
                                  try {
                                    controller
                                        ?.startVideoRecording()
                                        .then((value) => setState);
                                  } on CameraException catch (e) {
                                    showSnackBar(
                                        message: e.description ?? e.code);
                                  }
                                },
                        ),
                        IconButton(
                          icon: controller!.value.isRecordingPaused
                              ? const Icon(Icons.play_arrow)
                              : const Icon(Icons.pause),
                          color: Colors.blue,
                          onPressed: controller!.value.isInitialized &&
                                  controller!.value.isRecordingVideo
                              ? controller!.value.isRecordingPaused
                                  // Resume recording
                                  ? () async {
                                      try {
                                        controller
                                            ?.resumeVideoRecording()
                                            .then((value) {
                                          setState(() {});
                                          showSnackBar(
                                              message:
                                                  'Video recording resumed');
                                        });
                                      } on CameraException catch (e) {
                                        showSnackBar(
                                            message: e.description ?? e.code);
                                      }
                                    }
                                  // Pause recording
                                  : () async {
                                      try {
                                        controller
                                            ?.pauseVideoRecording()
                                            .then((value) {
                                          setState(() {});
                                          showSnackBar(
                                              message:
                                                  'Video recording paused');
                                        });
                                      } on CameraException catch (e) {
                                        showSnackBar(
                                            message: e.description ?? e.code);
                                      }
                                    }
                              : null,
                        ),
                        IconButton(
                          onPressed: _switchCamera,
                          icon: const Icon(Icons.restart_alt_rounded),
                        )
                      ],
                    ),
                  ],
                ),
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
}
