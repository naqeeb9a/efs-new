import 'dart:async';
import 'dart:io';

import 'package:efs_new/Database/models/attendance_model.dart';
import 'package:efs_new/Database/operations/attendance_operations.dart';
import 'package:efs_new/pages/appScreens/change_password.dart';
import 'package:efs_new/pages/appScreens/team_list.dart';
import 'package:efs_new/pages/appScreens/time_sheet.dart';
import 'package:efs_new/widgets/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'attendance.dart';
import 'device_id.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AttendanceOperations attendanceOperations = AttendanceOperations();
  SharedPreferences pref;
  SharedPreferences deviceid;
  SharedPreferences teamid;
  SharedPreferences teamname;
  String version = "2.1.0";

  var _loading = true;
  String syncStatus = "false";

  getSharedData() async {
    pref = await SharedPreferences.getInstance();
    deviceid = await SharedPreferences.getInstance();
    teamid = await SharedPreferences.getInstance();
    teamname = await SharedPreferences.getInstance();
    Globals.setTeamId(teamid.getString("teamid"));
    Globals.setDeviceId(deviceid.getString("deviceid"));
    Globals.setTeamName(teamname.getString("teamname"));
  }

  checkLoginStatus() async {
    pref = await SharedPreferences.getInstance();
    if (pref.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => DeviceId()),
          (Route<dynamic> route) => false);
    }
    Timer(Duration(seconds: 1), () {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    getSharedData();
    syncOnly();
  }

  Future<void> syncOnly() async {
    try {
      final net = await InternetAddress.lookup('example.com');
      if (net.isNotEmpty && net[0].rawAddress.isNotEmpty) {
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
                  "longitude_out":
                      attendanceDBData[i]["longitudeOut"].toString(),
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
                attendanceImage:
                    attendanceDBData[i]["attendanceImage"].toString(),
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
          Fluttertoast.showToast(
            msg: "Sync Data Completed!!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xff022b5e),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else if (syncStatus == "error") {
          Fluttertoast.showToast(
            msg: "Error!!\nCheck your Internet or Try Again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xff022b5e),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else if (syncStatus == "already") {
          Fluttertoast.showToast(
            msg: "Data already Synced!!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xff022b5e),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } on SocketException catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return _loading == true
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xff022b5e),
                strokeWidth: 4,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: Container(
                  width: width * 1,
                  height: height * .96,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChangePassword(
                                    name: "Change Password",
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.vpn_key_rounded,
                              size: MediaQuery.of(context).size.width * .07,
                              color: Color(0xffb1b1b1),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/logo.jpeg",
                            scale: 1.4,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Dashboard",
                            style: TextStyle(
                              fontSize: width * .06,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buttonContainer(
                            context,
                            "Team List",
                            Icons.group_rounded,
                            TeamList(),
                            0xff022b5e,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buttonContainer(
                            context,
                            "Mark Attendance",
                            Icons.markunread_mailbox_outlined,
                            Attendance(),
                            0xffc0d736,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buttonContainer(
                            context,
                            "Time Sheet",
                            Icons.event_note_outlined,
                            TimeSheet(),
                            0xffb1b1b1,
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * .1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Material(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10.0),
                              child: InkWell(
                                onTap: () async {
                                  setState(() {
                                    _loading = true;
                                  });

                                  await pref.remove("token");
                                  await teamid.remove("teamid");
                                  await teamname.remove("teamname");

                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              DeviceId()),
                                      (Route<dynamic> route) => false);
                                },
                                splashColor: Colors.white,
                                child: Container(
                                  width: MediaQuery.of(context).size.width * .4,
                                  height:
                                      MediaQuery.of(context).size.height * .084,
                                  child: Row(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .04,
                                            ),
                                            child: Icon(
                                              Icons.logout,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .08,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Logout",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .05,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height * .01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Version $version",
                              style: TextStyle(
                                fontSize: width * .038,
                                color: Color(0xffb1b1b1),
                              ),
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
}

Widget buttonContainer(
    BuildContext context, String title, icon, dynamic page, int color) {
  return Material(
    color: Color(color),
    borderRadius: BorderRadius.circular(10.0),
    child: InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => page),
        );
      },
      splashColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * .66,
        height: MediaQuery.of(context).size.height * .084,
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * .04,
                  ),
                  child: Icon(
                    icon,
                    // Icons.group_rounded,
                    size: MediaQuery.of(context).size.width * .08,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * .054,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
