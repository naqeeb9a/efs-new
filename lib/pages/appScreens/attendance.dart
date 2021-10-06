import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:efs_new/Database/models/attendance_model.dart';
import 'package:efs_new/Database/operations/attendance_operations.dart';
import 'package:efs_new/services/facenet.service.dart';
import 'package:efs_new/services/ml_vision_service.dart';
import 'package:efs_new/widgets/dialog_widget.dart';
import 'package:efs_new/widgets/globals.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'attendance_camera.dart';

class Attendance extends StatefulWidget {
  const Attendance({Key key}) : super(key: key);

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  AttendanceOperations attendanceOperations = AttendanceOperations();
  var latitude;
  var longitude;
  bool locationLoading = false;
  Position _currentPosition;

  bool checkOut = false;

  //get current location latitude or longitude
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        locationLoading = true;
        _currentPosition = position;
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
      });
    }).catchError((e) {
      print(e);
    });
  }

  // Services injection
  FaceNetService _faceNetService = FaceNetService();
  MLVisionService _mlVisionService = MLVisionService();

  CameraDescription cameraDescription;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        title: Text(
          "Mark Attendance",
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
          : Center(
              child: SingleChildScrollView(
                child: Container(
                  width: width * .9,
                  height: height * .7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: width * .86,
                            child: AutoSizeText(
                              "Open camera button below, Click Picture and then press Time In or Time Out Button.",
                              style: TextStyle(
                                color: Color(0xff022b5e),
                                fontSize: 24.0,
                              ),
                              maxLines: 2,
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: height * .06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          AttendanceCamera(
                                        cameraDescription: cameraDescription,
                                      ),
                                    ),
                                  );
                                },
                                splashColor: Colors.white,
                                child: cameraButton(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: height * .02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: width * .86,
                              child: AutoSizeText(
                                locationLoading == false
                                    ? "Latitude : is getting..."
                                    : "Latitude : $latitude",
                                style: TextStyle(
                                  color: Color(0xff022b5e),
                                  fontSize: 18.0,
                                ),
                                maxLines: 1,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: height * .02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: width * .86,
                              child: AutoSizeText(
                                locationLoading == false
                                    ? "Longitude : is getting..."
                                    : "Longitude : $longitude",
                                style: TextStyle(
                                  color: Color(0xff022b5e),
                                  fontSize: 18.0,
                                ),
                                maxLines: 1,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: height * .04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Material(
                                  color: Color(0xff66bb6a),
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      timeInAttendance(Globals.attendanceId);
                                    },
                                    splashColor: Colors.white,
                                    child: bottomButtons(
                                      context,
                                      "Time In",
                                      0xff66bb6a,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Material(
                                  color: Color(0xff022b5e),
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      timeOutAttendance(Globals.attendanceId);
                                    },
                                    splashColor: Colors.white,
                                    child: bottomButtons(
                                      context,
                                      "Time Out",
                                      0xff022b5e,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future timeInAttendance(String id) {
    String timeInCheck = "";
    dynamic attendanceData2;
    return attendanceOperations.searchAttendance(id).then((result) {
      var now = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');
      String difference =
      now.toString();
      String date = formatter.format(now);
      String completeDate = DateFormat.yMEd().add_jms().format(DateTime.now());
      if (latitude != null && longitude != null) {
        if (id == "null") {
          errorDialog(context, "First Take Picture!!!");
        } else {
          if (result.length == 0) {
            final attendanceData = AttendanceData(
              id: 0,
              employeeId: id,
              teamId: Globals.teamId,
              date: date,
              timeIn: completeDate,
              timeOut: "",
              latitudeIn: latitude.toString(),
              longitudeIn: longitude.toString(),
              latitudeOut: "",
              longitudeOut: "",
              attendanceImage: Globals.attendanceImage,
              syncStatus: "",
              updateTime: completeDate.toString(),
              differenceTime: difference.toString(),
            );
            attendanceOperations.createAttendance(attendanceData);
            successDialogOnly(context, "Check-In Attendance Marked!!");
            Globals.setAttendanceId("null");
            Future.delayed(Duration(milliseconds: 1000), () {
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 2);
            });
          } else {
            for (int i = 0; i < result.length; i++) {
              if (result.length > 0 &&
                  result[i]['employeeId'].toString() == id.toString() &&
                  result[i]['date'].toString() == date.toString() &&
                  result[i]['timeIn'].toString() != "" &&
                  result[i]['timeOut'].toString() != "") {
                attendanceData2 = AttendanceData(
                  id: 0,
                  employeeId: id,
                  teamId: Globals.teamId,
                  date: date,
                  timeIn: completeDate,
                  timeOut: "",
                  latitudeIn: latitude.toString(),
                  longitudeIn: longitude.toString(),
                  latitudeOut: "",
                  longitudeOut: "",
                  attendanceImage: Globals.attendanceImage,
                  syncStatus: "0",
                  updateTime: completeDate.toString(),
                  differenceTime: difference.toString(),
                );
                timeInCheck = "ok";
              } else if (result.length > 0 &&
                  result[i]['employeeId'].toString() == id.toString() &&
                  result[i]['date'].toString() != date.toString() &&
                  result[i]['timeIn'].toString() != "" &&
                  result[i]['timeOut'].toString() != "") {
                attendanceData2 = AttendanceData(
                  id: 0,
                  employeeId: id,
                  teamId: Globals.teamId,
                  date: date,
                  timeIn: completeDate,
                  timeOut: "",
                  latitudeIn: latitude.toString(),
                  longitudeIn: longitude.toString(),
                  latitudeOut: "",
                  longitudeOut: "",
                  attendanceImage: Globals.attendanceImage,
                  syncStatus: "0",
                  updateTime: completeDate.toString(),
                  differenceTime: difference.toString(),
                );
                timeInCheck = "ok";
              } else if (result.length > 0 &&
                  result[i]['employeeId'].toString() == id.toString() &&
                  result[i]['date'].toString() != date.toString() &&
                  result[i]['timeIn'].toString() != "" &&
                  result[i]['timeOut'].toString() == "") {
                attendanceData2 = AttendanceData(
                  id: 0,
                  employeeId: id,
                  teamId: Globals.teamId,
                  date: date,
                  timeIn: completeDate,
                  timeOut: "",
                  latitudeIn: latitude.toString(),
                  longitudeIn: longitude.toString(),
                  latitudeOut: "",
                  longitudeOut: "",
                  attendanceImage: Globals.attendanceImage,
                  syncStatus: "0",
                  updateTime: completeDate.toString(),
                  differenceTime: difference.toString(),
                );
                timeInCheck = "ok";
              } else if (result.length > 0 &&
                  result[i]['employeeId'].toString() == id.toString() &&
                  result[i]['date'].toString() == date.toString() &&
                  result[i]['timeIn'].toString() != "" &&
                  result[i]['timeOut'].toString() == "") {
                timeInCheck = "no";
              }
            }
            if (timeInCheck == "ok") {
              attendanceOperations.createAttendance(attendanceData2);
              successDialogOnly(context, "Check-In Attendance Marked!!");
              Globals.setAttendanceId("null");
              Future.delayed(Duration(milliseconds: 1000), () {
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              });
            } else if (timeInCheck == "no") {
              Globals.setAttendanceId("null");
              errorDialog(
                context,
                "You have already Check-In!!\nCheck-Out first and then try again!!",
              );
            }
          }
        }
      } else {
        errorDialog(
          context,
          "Location not Recorded.\nCheck your permissions and then try again!!",
        );
      }
    });
  }

  Future timeOutAttendance(String id) {
    String timeOutCheck = "";
    dynamic attendanceData2;
    String empid = "";
    return attendanceOperations.searchAttendance(id).then((result) {
      var now = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');
      String date = formatter.format(now);
      String completeDate = DateFormat.yMEd().add_jms().format(DateTime.now());
      if (latitude != null && longitude != null) {
        if (id == "null") {
          errorDialog(context, "First Take Picture!!!");
        } else {
          for (int i = 0; i < result.length; i++) {
            var completeDate2 = DateTime.now()
                .toString()
                .substring(0, DateTime.now().toString().length - 10);

            var one = DateTime.parse(completeDate2);
            var pTime = one
                .difference(
                    DateTime.parse(result[i]['differenceTime'].toString()))
                .toString();

            if (result[i]['timeOut'].toString() == "" &&
                int.parse(pTime.substring(0, pTime.length - 13)) <= 20) {
              if (result.length > 0 &&
                  result[i]['employeeId'].toString() == id.toString() &&
                  result[i]['timeIn'].toString() != "" &&
                  result[i]['timeOut'].toString() == "") {
                attendanceData2 = AttendanceData(
                  id: 0,
                  employeeId: id,
                  teamId: Globals.teamId,
                  date: date,
                  timeIn: result[i]['timeIn'],
                  timeOut: completeDate,
                  latitudeIn: result[i]['latitudeIn'].toString(),
                  longitudeIn: result[i]['longitudeIn'].toString(),
                  latitudeOut: latitude.toString(),
                  longitudeOut: longitude.toString(),
                  attendanceImage: Globals.attendanceImage,
                  syncStatus: "0",
                  updateTime: completeDate,
                  differenceTime: result[i]['differenceTime'].toString(),
                );
                timeOutCheck = "ok";
                empid = result[i]['id'].toString();
              } else if (result.length > 0 &&
                  result[i]['employeeId'].toString() == id.toString() &&
                  result[i]['date'].toString() == date.toString() &&
                  result[i]['timeIn'].toString() == "" &&
                  result[i]['timeOut'].toString() == "") {
                timeOutCheck = "no1";
              } else if (result.length > 0 &&
                  result[i]['employeeId'].toString() == id.toString() &&
                  result[i]['date'].toString() == date.toString() &&
                  result[i]['timeIn'].toString() != "" &&
                  result[i]['timeOut'].toString() != "") {
                timeOutCheck = "no2";
              }
            } else {
              timeOutCheck = "timeError";
            }
          }

          if (timeOutCheck == "ok") {
            attendanceOperations.updateAttendance(
                int.parse(empid), attendanceData2);
            successDialogOnly(context, "Check-Out Attendance Marked!!");
            Globals.setAttendanceId("null");
            Future.delayed(Duration(milliseconds: 1000), () {
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 2);
            });
          } else if (timeOutCheck == "no1") {
            Globals.setAttendanceId("null");
            errorDialog(
              context,
              "Check-In first and then try again!!",
            );
          } else if (timeOutCheck == "no2") {
            Globals.setAttendanceId("null");
            errorDialog(
              context,
              "You have already Check-Out!!\nCheck-In first and then try again!!",
            );
          } else if (timeOutCheck == "timeError") {
            Globals.setAttendanceId("null");
            errorDialog(
              context,
              "Time-Out Undetected.\nPlease Contact Admin.",
            );
          }
        }
      } else {
        errorDialog(
          context,
          "Location not Recorded.\nCheck your permissions and then try again!!",
        );
      }
    });
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

Widget bottomButtons(BuildContext context, String title, int color) {
  return Container(
    width: MediaQuery.of(context).size.width * .4,
    height: MediaQuery.of(context).size.height * .07,
    child: Center(
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).size.width * .044,
        ),
        maxLines: 1,
      ),
    ),
  );
}
