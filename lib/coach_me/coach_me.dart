import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:camera/camera.dart';

class CoachPage extends StatefulWidget {
  @override
  _CoachPageState createState() {
    return _CoachPageState();
  }
}

class _CoachPageState extends State {
  bool isPaused = true;
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
  static const MethodChannel _channel = const MethodChannel('tflite');
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {

      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });

        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      }else{
        print("No camera available");
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.medium);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: isPaused ? _cameraPreviewWidget()
                : _renderKeypoints(),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _cameraTogglesRowWidget(),
                  _captureControlRowWidget(context),
                  Spacer()
                ],
              ),
              SizedBox(height: 20.0)
            ],
          ),
        ),
      ),
    );
  }

  /// Display Camera preview.
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }

  /// Display the control bar with buttons to take pictures
  Widget _captureControlRowWidget(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingActionButton(
                child:(isPaused) ? Icon(Icons.play_arrow)
                    : Icon(Icons.pause),
                backgroundColor: Colors.blueGrey,
                onPressed: () {
                  setState(() {
                    isPaused = !isPaused;
                  });
                })
          ],
        ),
      ),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
            onPressed: _onSwitchCamera,
            icon: Icon(_getCameraLensIcon(lensDirection)),
            label: Text(
                "${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1)}")),
      ),
    );
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
    selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    _initCameraController(selectedCamera);
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    print('Error: ${e.code}\n${e.description}');
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res = await Tflite.loadModel(
          model: "assets/posenet.tflite");
      return res;
    } on PlatformException {
      print('Failed to load model.');
    }
  }
  Future<List> runPoseNetOnFrame(
      {@required List<Uint8List> bytesList,
        int imageHeight = 1280,
        int imageWidth = 720,
        double imageMean = 127.5,
        double imageStd = 127.5,
        int rotation: 90, // Android only
        int numResults = 5,
        double threshold = 0.5,
        int nmsRadius = 20,
        bool asynch = true}) async {
    return await _channel.invokeMethod(
      'runPoseNetOnFrame',
      {
        "bytesList": bytesList,
        "imageHeight": imageHeight,
        "imageWidth": imageWidth,
        "imageMean": imageMean,
        "imageStd": imageStd,
        "rotation": rotation,
        "numResults": numResults,
        "threshold": threshold,
        "nmsRadius": nmsRadius,
        "asynch": asynch,
      },
    );
  }

  List<Widget> _renderKeypoints() {
    var lists = <Widget>[];
    _recognitions.forEach((re) {
      var list = re["keypoints"].values.map<Widget>((k) {
        var x = k["x"];
        var y = k["y"];

        return Positioned(
          left: x - 6,
          top: y - 6,
          width: 100,
          height: 12,
          child: Container(
            child: Text(
              "● ${k["part"]}",
              style: TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 12.0,
              ),
            ),
          ),
        );
      }).toList();

      lists.addAll(list);
    });

    return lists;
  }
}


