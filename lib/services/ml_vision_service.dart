import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_vision/google_ml_vision.dart';

import 'camera.service.dart';

class MLVisionService {
  // singleton boilerplate
  static final MLVisionService _cameraServiceService =
      MLVisionService._internal();

  factory MLVisionService() {
    return _cameraServiceService;
  }

  // singleton boilerplate
  MLVisionService._internal();

  // service injection
  CameraService _cameraService = CameraService();

  FaceDetector _faceDetector;

  FaceDetector get faceDetector => this._faceDetector;

  void initialize() {
    this._faceDetector = GoogleVision.instance.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<List<Face>> getFacesFromImage(CameraImage image) async {
    /// preprocess the image  🧑🏻‍🔧
    GoogleVisionImageMetadata googleVisionImageMetadata =
        GoogleVisionImageMetadata(
      rotation: _cameraService.cameraRotation,
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      planeData: image.planes.map(
        (Plane plane) {
          return GoogleVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );

    /// Transform the image input for the _faceDetector 🎯
    GoogleVisionImage googleVisionImage = GoogleVisionImage.fromBytes(
        image.planes[0].bytes, googleVisionImageMetadata);

    /// proces the image and makes inference 🤖
    List<Face> faces = await this._faceDetector.processImage(googleVisionImage);

    return faces;
  }
}
