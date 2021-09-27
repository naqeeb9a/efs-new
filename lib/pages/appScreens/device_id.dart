import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:efs_new/Database/models/attendance_model.dart';
import 'package:efs_new/Database/models/employee_model.dart';
import 'package:efs_new/Database/operations/attendance_operations.dart';
import 'package:efs_new/Database/operations/employee_operations.dart';
import 'package:efs_new/Database/operations/team_operations.dart';
import 'package:efs_new/pages/API/api.dart';
import 'package:efs_new/widgets/dialog_widget.dart';
import 'package:efs_new/widgets/globals.dart';
import 'package:efs_new/widgets/text_field.dart' as field;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

final deviceId = TextEditingController();
final _formKey = GlobalKey<FormState>();

class DeviceId extends StatefulWidget {
  const DeviceId({Key key}) : super(key: key);

  @override
  _DeviceIdState createState() => _DeviceIdState();
}

class _DeviceIdState extends State<DeviceId> {
  SharedPreferences prefDeviceId;
  SharedPreferences pref;

  AttendanceOperations attendanceOperations = AttendanceOperations();

  String syncStatus = "false";

  saveDeviceId() async {
    SharedPreferences deviceid = await SharedPreferences.getInstance();
    deviceid.setString("deviceid", deviceId.text);
  }

  getSharedData() async {
    pref = await SharedPreferences.getInstance();
    prefDeviceId = await SharedPreferences.getInstance();
    Globals.setDeviceId(prefDeviceId.getString("deviceid"));
  }

  Future<void> syncData() async {
    syncStatus = "false";

    var attendanceDBData = await attendanceOperations.getAttendance();
    for (int i = 0; i < attendanceDBData.length; i++) {
      if (attendanceDBData[i]["syncStatus"].toString() == "0") {
        var response = await http.post(
            Uri.parse(
                "https://attendanceapp.genxmtech.com/api/saveEmployeeAttendance"),
            body: {
              "employee_id": attendanceDBData[i]["employeeId"].toString(),
              "team_id": attendanceDBData[i]["teamId"].toString(),
              "date": attendanceDBData[i]["date"],
              "time_out": attendanceDBData[i]["timeOut"].toString(),
              "time_in": attendanceDBData[i]["timeIn"].toString(),
              "longitude_in": attendanceDBData[i]["longitudeIn"].toString(),
              "latitude_in": attendanceDBData[i]["latitudeIn"].toString(),
              "longitude_out": attendanceDBData[i]["longitudeOut"].toString(),
              "latitude_out": attendanceDBData[i]["latitudeOut"].toString(),
              "attendance_image":
                  attendanceDBData[i]["attendanceImage"].toString(),
              "sync_status": attendanceDBData[i]["syncStatus"].toString(),
              "updated_at": "",
              "created_at": ""
            });
        if (response.statusCode == 200) {
          final attendanceData = AttendanceData(
            id: 0,
            employeeId: attendanceDBData[i]["employeeId"].toString(),
            teamId: attendanceDBData[i]["teamId"].toString(),
            date: attendanceDBData[i]["date"],
            timeIn: attendanceDBData[i]["timeIn"].toString(),
            timeOut: attendanceDBData[i]["timeOut"].toString(),
            latitudeIn: attendanceDBData[i]["latitudeIn"].toString(),
            longitudeIn: attendanceDBData[i]["longitudeIn"].toString(),
            latitudeOut: attendanceDBData[i]["latitudeOut"].toString(),
            longitudeOut: attendanceDBData[i]["longitudeOut"].toString(),
            attendanceImage: attendanceDBData[i]["attendanceImage"].toString(),
            syncStatus: "1",
          );
          attendanceOperations.updateAttendance(
              attendanceDBData[i]['id'], attendanceData);
          syncStatus = "true";
        } else {
          syncStatus = "error";
        }
      } else if (attendanceDBData[i]["syncStatus"].toString() == "1") {
        syncStatus = "already";
      }
    }
    if (syncStatus == "true") {
      successDialog(context, "Sync Data Completed!!");
    } else if (syncStatus == "error") {
      errorDialog(context, "Error!!\nCheck your Internet or Try Again");
    } else if (syncStatus == "already") {
      successDialog(context, "Data already Synced!!");
    }
  }

  Future<void> syncAllEmployees() async {
    syncStatus = "false";
    var allEmployeeData = await EmployeeOperations().getAllEmployees();
    for (int i = 0; i < allEmployeeData.length; i++) {
      if (allEmployeeData[i]["isSync"].toString() == "0") {
        var response = await http.post(
            Uri.parse("https://attendanceapp.genxmtech.com/api/addEmployee"),
            body: {
              "employee_id": allEmployeeData[i]["employeeId"].toString(),
              "employee_name": allEmployeeData[i]["employeeName"].toString(),
              "department": allEmployeeData[i]["department"].toString(),
              "team_id": allEmployeeData[i]["teamId"].toString(),
              "designation": allEmployeeData[i]["designation"].toString(),
              "status": allEmployeeData[i]["status"].toString(),
              "updated_at": "",
              "created_at": "",
            });
        if (response.statusCode == 200) {
          final employee = Employee(
            id: 0,
            employeeId: allEmployeeData[i]["employeeId"].toString(),
            employeeName: allEmployeeData[i]["employeeName"].toString(),
            department: allEmployeeData[i]["department"].toString(),
            designation: allEmployeeData[i]["designation"].toString(),
            image: allEmployeeData[i]["image"].toString(),
            teamId: allEmployeeData[i]["teamId"].toString(),
            status: allEmployeeData[i]["status"].toString(),
            isTeamLead: allEmployeeData[i]["isTeamLead"].toString(),
            username: allEmployeeData[i]["username"].toString(),
            password: allEmployeeData[i]["password"].toString(),
            teamName: allEmployeeData[i]["teamName"].toString(),
            isSync: "1",
            imageData: allEmployeeData[i]["imageData"].toString(),
          );

          syncStatus = "true";

          EmployeeOperations().updateEmployee(
            allEmployeeData[i]["employeeId"].toString(),
            employee,
          );
        } else {
          syncStatus = "error";
        }
      } else if (allEmployeeData[i]["isSync"].toString() == "1") {
        syncStatus = "already";
      }
    }

    if (syncStatus == "true") {
      successDialogOnly(context, "Sync Data Completed!!");
    } else if (syncStatus == "error") {
      errorDialogOnly(context, "Error!!\nCheck your Internet or Try Again");
    } else if (syncStatus == "already") {
      successDialogOnly(context, "Data already Synced!!");
    }
  }

  bool isLoading = false;

  // ignore: missing_return
  Future getDevice(BuildContext context, String id) async {
    try {
      final net = await InternetAddress.lookup('example.com');
      if (net.isNotEmpty && net[0].rawAddress.isNotEmpty) {
        ApiData().fetchTeamEmployeesInfo(id).then((result) async {
          if (result != null && result != false) {
            Globals.setDeviceId(deviceId.text);
            await saveDeviceId();

            setState(() {
              isLoading = false;
            });
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Login(),
              ),
            );
            deviceId.clear();
          } else {
            errorDialog(context, "Device ID Not Found!!");
            setState(() {
              isLoading = false;
            });
          }
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isLoading = false;
      });
      errorDialog(context, "No Internet Connection!");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedData();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: width * .9,
          height: height * .8,
          child: Form(
            key: _formKey,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .01,
                      bottom: MediaQuery.of(context).size.height * .04,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          "Enter your Device Id",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: width * .05,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .02,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child:
                              field.textField(context, deviceId, "Device Id"),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        continueButton(context),
                      ],
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

  Widget continueButton(BuildContext context) {
    return isLoading == false
        ? Material(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10.0),
            child: InkWell(
                onTap: () async {
                  if (deviceId.text == "") {
                    errorDialog(context, "Enter Device Id!!");
                  } else if (prefDeviceId.getString("deviceid") ==
                      deviceId.text) {
                    getDevice(context, deviceId.text);
                    setState(() {
                      isLoading = true;
                    });
                  } else if (prefDeviceId.getString("deviceid") !=
                      deviceId.text) {
                    await syncData();
                    await syncAllEmployees();
                    await pref.clear();
                    await EmployeeOperations().clearEmployeeDb();
                    await TeamOperations().clearTeamDb();
                    await AttendanceOperations().clearAttendanceDb();
                    getDevice(context, deviceId.text);
                    setState(() {
                      isLoading = true;
                    });
                  } else {
                    getDevice(context, deviceId.text);
                    setState(() {
                      isLoading = true;
                    });
                  }
                },
                splashColor: Colors.white,
                child: Container(
                  width: MediaQuery.of(context).size.width * .5,
                  height: MediaQuery.of(context).size.height * .07,
                  child: Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * .05,
                      ),
                    ),
                  ),
                )),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
