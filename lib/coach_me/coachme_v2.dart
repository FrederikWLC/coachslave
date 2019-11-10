import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'dart:math' as math;

class CoachPage extends StatefulWidget {
  @override
  _CoachPageState createState() {
    return _CoachPageState();
  }
}

class _CoachPageState extends State<CoachPage> {
  bool isPaused = true;
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String model;
  List<dynamic> _recognitions;
  int imageHeight;
  int imageWidth;
  var tmp;
  double previewH;
  double previewW;
  double screenH;
  double screenW;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {

      cameras = availableCameras;
      loadModel();
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });
        _initCameraController(cameras[selectedCameraIdx]);
        }
      else{
        print("No camera available");
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  void _initCameraController(CameraDescription cameraDescription) {
    controller = CameraController(cameraDescription, ResolutionPreset.low);
    controller.initialize().then((_) {
      previewH = math.max(controller.value.previewSize.height, controller.value.previewSize.width);
      previewW = math.min(controller.value.previewSize.height, controller.value.previewSize.width);
      controller.startImageStream(onAvailable);
      });



  }

  dynamic onAvailable(CameraImage img) async {
    if (!isPaused) {
      Tflite.runPoseNetOnFrame(bytesList: img.planes.map((plane) {
        return plane.bytes;
      }).toList(),
          imageHeight: img.height,
          imageWidth: img.width,
          numResults: 1).then((recognitions) {
        setState(() {
          _recognitions = recognitions;
        });
      });
    }
  }

  @override
  void dispose() {
  controller?.dispose();
  super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var tmp = MediaQuery.of(context).size;
    screenH = math.max(tmp.height, tmp.width);
    screenW = math.min(tmp.height, tmp.width);



    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: _cameraPreviewWidget()
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _cameraTogglesRowWidget(),
                  _captureControlRowWidget(context),
                  Spacer(),
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
    if (!(_recognitions == null )) {

    if (!isPaused && _recognitions.isNotEmpty){
        return Stack(
            children: <Widget>[CameraPreview(controller)] + _renderKeypoints());
    } }
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

  Future<Null> loadModel() async {
    try {
      final String result = await Tflite.loadModel(model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
    }
    on PlatformException catch (e) {
      print("Error: ${e.code}\nError Message: ${e.message}");
    }
  }

  List<Widget> _renderKeypoints() {
    var lists = <Widget>[];
    _recognitions.forEach((re) {
      var list = re["keypoints"].values.map<Widget>((k) {
        var _x = k["x"];
        var _y = k["y"];
        var scaleW, scaleH, x, y;

        if (screenH / screenW > previewH / previewW) {
          scaleW = screenH / previewH * previewW;
          scaleH = screenH;
          var difW = (scaleW - screenW) / scaleW;
          x = (_x - difW / 2) * scaleW;
          y = _y * scaleH;
        } else {
          scaleH = screenW / previewW * previewH;
          scaleW = screenW;
          var difH = (scaleH - screenH) / scaleH;
          x = _x * scaleW;
          y = (_y - difH / 2) * scaleH;
        }

        return Positioned(
          left: x-6,
          top: y-6,
          width: 100,
          height: 12,
          child: Container(
            child: Text(
              "●",
              style: TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 12.0,
              ),
            ),
          ),
        );
       }).toList();
      lists..addAll(list);
    });
    return lists;
  }
}




