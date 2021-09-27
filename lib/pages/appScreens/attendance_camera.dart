import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:efs_new/services/camera.service.dart';
import 'package:efs_new/services/facenet.service.dart';
import 'package:efs_new/services/ml_vision_service.dart';
import 'package:efs_new/widgets/FacePainter.dart';
import 'package:efs_new/widgets/camera_header.dart';
import 'package:efs_new/widgets/dialog_widget.dart';
import 'package:efs_new/widgets/globals.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_vision/google_ml_vision.dart';

class AttendanceCamera extends StatefulWidget {
  final CameraDescription cameraDescription;

  const AttendanceCamera({
    Key key,
    @required this.cameraDescription,
  }) : super(key: key);

  @override
  AttendanceCameraState createState() => AttendanceCameraState();
}

class AttendanceCameraState extends State<AttendanceCamera> {
  String imagePath;
  XFile file;
  Face faceDetected;
  Size imageSize;
  bool cameraLoader = false;

  bool _detectingFaces = false;
  bool pictureTaked = false;

  Future _initializeControllerFuture;
  bool cameraInitializated = false;

  // switchs when the user press the camera
  bool _saving = false;
  bool _bottomSheetVisible = false;

  // service injection
  MLVisionService _mlVisionService = MLVisionService();
  CameraService _cameraService = CameraService();
  FaceNetService _faceNetService = FaceNetService();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), () {
      _start();
    });
    Fluttertoast.showToast(
      msg: "Wait until Green Box Detects you!!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: Color(0xff022b5e),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// starts the camera & start framing faces
  _start() async {
    _initializeControllerFuture =
        _cameraService.startService(widget.cameraDescription);
    await _initializeControllerFuture;

    setState(() {
      cameraInitializated = true;
    });

    _frameFaces();
  }

  /// handles the button pressed event
  Future<dynamic> onShot() async {
    Globals.setAttendanceImage("null");
    if (faceDetected == null) {
      errorDialog(context, "No Face Detected");
      cameraLoader = false;
      return false;
    } else {
      _saving = true;
      await Future.delayed(Duration(milliseconds: 500));
      await _cameraService.cameraController.stopImageStream();
      await Future.delayed(Duration(milliseconds: 200));
      file = await _cameraService.takePicture();

      final bytes = Io.File(file.path).readAsBytesSync();

      String img64 = base64Encode(bytes);

      imagePath = img64;
      Globals.setAttendanceImage(imagePath);

      setState(() {
        _bottomSheetVisible = true;
        pictureTaked = true;
      });

      return true;
    }
  }

  /// draws rectangles when detects faces
  _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        // if its currently busy, avoids overprocessing
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          List<Face> faces = await _mlVisionService.getFacesFromImage(image);

          if (faces.length > 0) {
            setState(() {
              faceDetected = faces[0];
            });

            if (_saving) {
              _faceNetService.setCurrentPrediction(image, faceDetected);
              setState(() {
                _saving = false;
              });
            }
          } else {
            setState(() {
              faceDetected = null;
            });
          }

          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (pictureTaked) {
                    Uint8List bytes = Base64Codec().decode(imagePath);
                    return Container(
                      width: width,
                      height: height,
                      child: Transform(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image.memory(bytes),
                          ),
                          transform: Matrix4.rotationY(mirror)),
                    );
                  } else {
                    return Transform.scale(
                      scale: 1.0,
                      child: AspectRatio(
                        aspectRatio: MediaQuery.of(context).size.aspectRatio,
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Container(
                              width: width,
                              height: width *
                                  _cameraService
                                      .cameraController.value.aspectRatio,
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  CameraPreview(
                                      _cameraService.cameraController),
                                  CustomPaint(
                                    painter: FacePainter(
                                        face: faceDetected,
                                        imageSize: imageSize),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            CameraHeader(
              "Attendance",
              onBackPressed: _onBackPressed,
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:
            !_bottomSheetVisible ? captureButton() : Container());
  }

  Widget captureButton() {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: Color(0xff022b5e),
      child: InkWell(
        onTap: () async {
          Fluttertoast.showToast(
            msg: "Please wait and hold still!!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Color(0xff022b5e),
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            cameraLoader = true;
          });
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;
            // onShot event (takes the image and predict output)
            bool faceDetected = await onShot();

            if (faceDetected) {
              _faceNetService.predict();
              Future.delayed(Duration(milliseconds: 400), () {
                if (Globals.attendanceId != "null") {
                  successDialogOnly(
                      context, "Face Recognised as : " + Globals.attendanceId);
                  Future.delayed(Duration(milliseconds: 1500), () {
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                  });
                } else {
                  errorDialogOnly(context,
                      "1 - Face Recognition Error!\n2 - Register your Face First\nTry Again!!");
                  Future.delayed(Duration(milliseconds: 1500), () {
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                  });
                }
              });
            }
          } catch (e) {
            print(e);
          }
        },
        splashColor: Colors.white,
        child: cameraLoader == false
            ? Container(
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                width: MediaQuery.of(context).size.width * 0.8,
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CAPTURE',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.camera_alt, color: Colors.white)
                  ],
                ),
              )
            : CircularProgressIndicator(
                color: Colors.white,
              ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}
