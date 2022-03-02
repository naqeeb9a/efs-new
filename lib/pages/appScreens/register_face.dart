import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:efs_new/pages/appScreens/register_camera.dart';
import 'package:efs_new/services/facenet.service.dart';
import 'package:efs_new/services/ml_vision_service.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RegisterFace extends StatefulWidget {
  String employeeId,
      employeeName,
      designation,
      department,
      isTeamLead,
      username,
      password,
      image,
      status,
      isSync,
      imageData;

  RegisterFace({
    this.employeeId,
    this.employeeName,
    this.designation,
    this.department,
    this.isTeamLead,
    this.username,
    this.password,
    this.image,
    this.isSync,
    this.status,
    this.imageData,
  });

  @override
  _RegisterFaceState createState() => _RegisterFaceState();
}

class _RegisterFaceState extends State<RegisterFace> {
  // Services injection
  FaceNetService _faceNetService = FaceNetService();
  MLVisionService _mlVisionService = MLVisionService();

  CameraDescription cameraDescription;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _setLoading(true);
    Future.delayed(const Duration(milliseconds: 300), () {
      _startUp();
    });
  }

  /// 1 Obtain a list of the available cameras on the device.
  /// 2 loads the face net model
  _startUp() async {
    List<CameraDescription> cameras = await availableCameras();

    /// takes the front camera
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );

    // start the services
    await _faceNetService.loadModel();
    _mlVisionService.initialize();

    _setLoading(false);
  }

  // shows or hides the circular progress indicator
  _setLoading(bool value) {
    setState(() {
      loading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xfff2f2f2),
        appBar: AppBar(
          title: Text(
            "Face Registration",
            style: TextStyle(
              color: Colors.black,
              fontSize: width * .054,
            ),
          ),
          iconTheme: IconThemeData(
            color: Color(0xff022b5e),
          ),
          backgroundColor: Color(0xfff2f2f2),
          elevation: 4.0,
          centerTitle: true,
        ),
        body: loading == true
            ? Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: width * .9,
                    height: height * .8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: height * .02,
                          ),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: width * .36,
                                    child: AutoSizeText(
                                      "Employee Id: ",
                                      style: TextStyle(
                                        color: Color(0xff022b5e),
                                        fontSize: width * .046,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: width * .44,
                                    child: AutoSizeText(
                                      widget.employeeId,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: width * .042,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: height * .02,
                          ),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: width * .36,
                                    child: AutoSizeText(
                                      "Name: ",
                                      style: TextStyle(
                                        color: Color(0xff022b5e),
                                        fontSize: width * .046,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: width * .42,
                                    child: Text(
                                      widget.employeeName,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: width * .046,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: height * .02,
                          ),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: width * .36,
                                    child: AutoSizeText(
                                      "Designation: ",
                                      style: TextStyle(
                                        color: Color(0xff022b5e),
                                        fontSize: width * .046,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: width * .44,
                                    child: Text(
                                      widget.designation,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: width * .042,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: height * .04,
                          ),
                          child: AutoSizeText(
                            "Click button down below to click image for Facial Recognition",
                            style: TextStyle(
                              color: Color(0xff022b5e),
                              fontSize: width * .04,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: height * .02,
                          ),
                          child: Material(
                            color: Color(0xff022b5e),
                            borderRadius: BorderRadius.circular(10.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        RegisterCamera(
                                      cameraDescription: cameraDescription,
                                      employeeId: widget.employeeId,
                                      employeeName: widget.employeeName,
                                      designation: widget.designation,
                                      department: widget.department,
                                      isTeamLead: widget.isTeamLead,
                                      username: widget.username,
                                      password: widget.password,
                                      image: widget.image,
                                      status: widget.status,
                                      isSync: widget.isSync,
                                      imageData: widget.imageData,
                                    ),
                                  ),
                                );
                              },
                              splashColor: Colors.white,
                              child: cameraButton(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

Widget cameraButton(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * .6,
    height: MediaQuery.of(context).size.height * .07,
    child: Center(
      child: Icon(
        Icons.camera_alt_outlined,
        color: Colors.white,
        size: MediaQuery.of(context).size.width * .08,
      ),
    ),
  );
}
