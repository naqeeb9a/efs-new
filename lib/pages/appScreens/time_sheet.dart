import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:efs_new/Database/models/attendance_model.dart';
import 'package:efs_new/Database/operations/attendance_operations.dart';
import 'package:efs_new/widgets/dialog_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'maps.dart';

var format = DateFormat("HH:mm");

class TimeSheet extends StatefulWidget {
  const TimeSheet({Key key}) : super(key: key);

  @override
  _TimeSheetState createState() => _TimeSheetState();
}

class _TimeSheetState extends State<TimeSheet> {
  AttendanceOperations attendanceOperations = AttendanceOperations();
  Future<List> attendancesData, attendancesDataByOrder;

  String syncStatus = "false";
  bool dataSync = false;

  Future<void> checkRemainingDays() async {
    SharedPreferences datetime = await SharedPreferences.getInstance();
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String date = formatter.format(now);
    if (datetime.getString("datetime") == null) {
      datetime.setString("datetime", date);
    } else {
      var getDate = datetime.getString("datetime");
      DateTime dateTimeCreatedAt = DateTime.parse(getDate);
      DateTime dateTimeNow = DateTime.now();
      final differenceInDays = dateTimeNow.difference(dateTimeCreatedAt).inDays;

      if (differenceInDays >= 45) {
        try {
          final net = await InternetAddress.lookup('example.com');
          if (net.isNotEmpty && net[0].rawAddress.isNotEmpty) {
            await syncData();
            if (dataSync == true) {
              await datetime.setString("datetime", date);
              await attendanceOperations.clearAttendanceDb();
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimeSheet(),
                ),
              );
            }
          }
        } on SocketException catch (_) {}
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkRemainingDays();
    attendancesData = attendanceOperations.getAttendance();
    attendancesDataByOrder = attendanceOperations.getAttendanceByOrder();
  }

  Future<void> syncData() async {
    syncStatus = "false";
    setState(() {
      dataSync = false;
    });
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
      setState(() {
        dataSync = true;
      });
      successDialog(context, "Sync Data Completed!!");
    } else if (syncStatus == "error") {
      errorDialog(context, "Error!!\nCheck your Internet or Try Again");
    } else if (syncStatus == "already") {
      successDialog(context, "Data already Synced!!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        title: Text(
          "Time Sheet",
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
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                syncButton(context);
              },
              splashColor: Color(0xff022b5e),
              child: Icon(
                Icons.sync,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: width * .94,
            height: height * .86,
            child: Column(
              children: [
                // Padding(
                //   padding:
                //       EdgeInsets.only(top: height * .016, bottom: height * .01),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Material(
                //         color: Color(0xff022b5e),
                //         borderRadius: BorderRadius.circular(10.0),
                //         child: InkWell(
                //           onTap: () {
                //             syncData();
                //           },
                //           splashColor: Colors.white,
                //           child: syncButton(context),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                FutureBuilder(
                  future: attendancesDataByOrder,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        width: width * .94,
                        height: height * .76,
                        child: ListView.builder(
                            itemCount: (snapshot.data as List).length,
                            itemBuilder: (context, i) {
                              return cardContainer(
                                context,
                                (snapshot.data as List)[i]['employeeId']
                                    .toString(),
                                (snapshot.data as List)[i]['timeIn'].toString(),
                                (snapshot.data as List)[i]['timeOut']
                                    .toString(),
                                (snapshot.data as List)[i]['attendanceImage']
                                    .toString(),
                                (snapshot.data as List)[i]['longitudeIn']
                                    .toString(),
                                (snapshot.data as List)[i]['latitudeIn']
                                    .toString(),
                                (snapshot.data as List)[i]['longitudeOut']
                                    .toString(),
                                (snapshot.data as List)[i]['latitudeOut']
                                    .toString(),
                                (snapshot.data as List)[i]['differenceTime']
                                    .toString(),
                              );
                            }),
                      );
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget syncButton(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * .7,
    height: MediaQuery.of(context).size.height * .07,
    child: Center(
      child: Text(
        "Sync All Data",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: MediaQuery.of(context).size.width * .05,
        ),
      ),
    ),
  );
}

convertTime(time, context) {
  print(time);
  print((" ".allMatches(time.toString().substring(14))).length);
  print(time.length);
  print(time.toString().substring(14));
  print(time.toString().substring(14).length);
  if (time.toString().substring(14).contains("AM") ||
      (time.toString().substring(14).contains("12") &&
          time.toString().substring(14).contains("PM"))) {
    if (time.length == 24 && time.toString().substring(14).length == 10) {
      time = time.toString().substring(9, 13) +
          "-0" +
          time.toString().substring(5, 6) +
          "-0" +
          time.toString().substring(7, 8) +
          " 0" +
          time.toString().substring(15, 19);
    } else if (time.length == 25 &&
        time.toString().substring(14).length == 11 &&
        (" ".allMatches(time.toString().substring(14))).length == 2) {
      if ((time.toString().substring(10, 14) +
              "-0" +
              time.toString().substring(5, 6) +
              "-" +
              time.toString().substring(7, 9))
          .contains("/")) {
        time = time.toString().substring(10, 14) +
            "-" +
            time.toString().substring(5, 7) +
            "-0" +
            time.toString().substring(8, 9) +
            " 0" +
            time.toString().substring(15, 19);
      } else {
        time = time.toString().substring(10, 14) +
            "-0" +
            time.toString().substring(5, 6) +
            "-" +
            time.toString().substring(7, 9) +
            " 0" +
            time.toString().substring(15, 19);
      }
    } else if (time.length == 25 &&
        time.toString().substring(14).length == 11) {
      time = time.toString().substring(9, 13) +
          "-0" +
          time.toString().substring(5, 6) +
          "-0" +
          time.toString().substring(7, 8) +
          " " +
          time.toString().substring(14, 19);
    } else if (time.length == 26 &&
        time.toString().substring(14).length == 12 &&
        (" ".allMatches(time.toString().substring(14))).length == 2 &&
        time.toString().substring(14)[0] == "1") {
      time = time.toString().substring(11, 15) +
          "-" +
          time.toString().substring(5, 7) +
          "-" +
          time.toString().substring(8, 10) +
          " 0" +
          time.toString().substring(16, 20);
    } else if (time.length == 26 &&
        time.toString().substring(14).length == 12) {
      if ((time.toString().substring(10, 14) +
              "-0" +
              time.toString().substring(5, 6) +
              "-" +
              time.toString().substring(7, 9))
          .contains("/")) {
        time = time.toString().substring(10, 14) +
            "-" +
            time.toString().substring(5, 7) +
            "-0" +
            time.toString().substring(8, 9) +
            time.toString().substring(14, 20);
      } else {
        time = time.toString().substring(10, 14) +
            "-0" +
            time.toString().substring(5, 6) +
            "-" +
            time.toString().substring(7, 9) +
            time.toString().substring(14, 20);
      }
    } else if (time.length == 27 &&
        time.toString().substring(14).length == 13) {
      time = time.toString().substring(11, 15) +
          "-" +
          time.toString().substring(5, 7) +
          "-" +
          time.toString().substring(8, 10) +
          time.toString().substring(15, 21);
    }
  } else if (time.toString().substring(14).contains("PM") ||
      (time.toString().substring(14).contains("12") &&
          time.toString().substring(14).contains("AM"))) {
    if (time.length == 24 && time.toString().substring(14).length == 10) {
      time = time.toString().substring(9, 13) +
          "-0" +
          time.toString().substring(5, 6) +
          "-0" +
          time.toString().substring(7, 8) +
          " " +
          (int.parse(time.toString().substring(15, 16)) + 12).toString() +
          time.toString().substring(16, 19);
    } else if (time.length == 25 &&
        time.toString().substring(14).length == 11 &&
        (" ".allMatches(time.toString().substring(14))).length == 2) {
      if ((time.toString().substring(10, 14) +
              "-0" +
              time.toString().substring(5, 6) +
              "-" +
              time.toString().substring(7, 9))
          .contains("/")) {
        time = time.toString().substring(10, 14) +
            "-" +
            time.toString().substring(5, 7) +
            "-0" +
            time.toString().substring(8, 9) +
            " " +
            (int.parse(time.toString().substring(15, 16)) + 12).toString() +
            time.toString().substring(16, 19);
      } else {
        time = time.toString().substring(10, 14) +
            "-0" +
            time.toString().substring(5, 6) +
            "-" +
            time.toString().substring(7, 9) +
            " " +
            (int.parse(time.toString().substring(15, 16)) + 12).toString() +
            time.toString().substring(16, 19);
      }
    } else if (time.length == 25 &&
        time.toString().substring(14).length == 11) {
      time = time.toString().substring(9, 13) +
          "-0" +
          time.toString().substring(5, 6) +
          "-0" +
          time.toString().substring(7, 8) +
          " " +
          (int.parse(time.toString().substring(14, 16)) + 12).toString() +
          time.toString().substring(16, 19);
    } else if (time.length == 26 &&
        time.toString().substring(14).length == 12 &&
        (" ".allMatches(time.toString().substring(14))).length == 2 &&
        time.toString().substring(14)[0] == "1") {
      time = time.toString().substring(11, 15) +
          "-" +
          time.toString().substring(5, 7) +
          "-" +
          time.toString().substring(8, 10) +
          " " +
          (int.parse(time.toString().substring(16, 17)) + 12).toString() +
          time.toString().substring(17, 20);
    } else if (time.length == 26 &&
        time.toString().substring(14).length == 12) {
      if ((time.toString().substring(10, 14) +
              "-0" +
              time.toString().substring(5, 6) +
              "-" +
              time.toString().substring(7, 9))
          .contains("/")) {
        time = time.toString().substring(10, 14) +
            "-" +
            time.toString().substring(5, 7) +
            "-0" +
            time.toString().substring(8, 9) +
            " " +
            (int.parse(time.toString().substring(15, 16)) + 12).toString() +
            time.toString().substring(16, 20);
      } else {
        time = time.toString().substring(10, 14) +
            "-0" +
            time.toString().substring(5, 6) +
            "-" +
            time.toString().substring(7, 9) +
            (int.parse(time.toString().substring(15, 16)) + 12).toString() +
            time.toString().substring(16, 20);
      }
    } else if (time.length == 27 &&
        time.toString().substring(14).length == 13) {
      time = time.toString().substring(11, 15) +
          "-" +
          time.toString().substring(5, 7) +
          "-" +
          time.toString().substring(8, 10) +
          " " +
          (int.parse(time.toString().substring(16, 18)) + 12).toString() +
          time.toString().substring(18, 21);
    }
  } else {
    errorDialog(context, "Error");
  }
  return time;
}
// convertTime(time) {
//   var parsedTime = "";
//   if (time.toString().substring(4, 6).contains(" ")) {
//     parsedTime = "0" + time.toString().substring(5, 6);
//   } else {
//     parsedTime = time.toString().substring(4, 6);
//   }
//   var timeDate = time.toString().substring(10, 14) +
//       "-" +
//       parsedTime +
//       "-" +
//       time.toString().substring(7, 9);

//   return timeDate;
// }

Widget cardContainer(
  BuildContext context,
  String employeeId,
  timeIn,
  timeOut,
  image,
  longitudeIn,
  latitudeIn,
  longitudeOut,
  latitudeOut,
  differenceTime,
) {
  Uint8List bytes = Base64Codec().decode(image);

  var completeDate = DateTime.now()
      .toString()
      .substring(0, DateTime.now().toString().length - 10);

  var one = DateTime.parse(completeDate);
  var pTime = one.difference(DateTime.parse(differenceTime)).toString();
  print(pTime);
  bool timeDifference = false;

  if (timeOut == "" && int.parse(pTime.substring(0, pTime.length - 13)) >= 20) {
    timeDifference = true;
  }

  return Container(
    width: MediaQuery.of(context).size.width * .94,
    height: MediaQuery.of(context).size.height * .23,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          spreadRadius: 2,
          blurRadius: 4,
          offset: Offset(0, 3),
        ),
      ],
    ),
    margin: EdgeInsets.symmetric(
      vertical: MediaQuery.of(context).size.height * .016,
      horizontal: MediaQuery.of(context).size.width * .016,
    ),
    padding: EdgeInsets.all(MediaQuery.of(context).size.width * .03),
    child: Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            bytes == null
                ? Container(
                    width: MediaQuery.of(context).size.width * .24,
                    height: MediaQuery.of(context).size.height * .194,
                    decoration: BoxDecoration(
                      color: Color(0xff022b5e),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width * .24,
                    height: MediaQuery.of(context).size.height * .194,
                    decoration: BoxDecoration(
                      color: Color(0xff022b5e),
                      borderRadius: BorderRadius.circular(12.0),
                      image: DecorationImage(
                        image: MemoryImage(
                          bytes,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * .03,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .548,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            "Employee ID: ",
                            style: TextStyle(
                              color: Color(0xff022b5e),
                              fontSize:
                                  MediaQuery.of(context).size.width * .034,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .32,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            employeeId.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.width * .034,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .22,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              "Time In: ",
                              style: TextStyle(
                                color: Color(0xff022b5e),
                                fontSize:
                                    MediaQuery.of(context).size.width * .034,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .32,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              timeIn,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width * .034,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .22,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              "Time Out: ",
                              style: TextStyle(
                                color: Color(0xff022b5e),
                                fontSize:
                                    MediaQuery.of(context).size.width * .034,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .32,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              // timeOut,
                              timeDifference == false
                                  ? timeOut
                                  : "Time-Out Undetected. Please Contact Admin.",
                              style: TextStyle(
                                color: timeDifference == false
                                    ? Colors.black
                                    : Colors.red,
                                fontSize:
                                    MediaQuery.of(context).size.width * .034,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Material(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8.0),
                          child: InkWell(
                            onTap: () {
                              if (latitudeIn == "" && longitudeIn == "") {
                                errorDialog(context,
                                    "No Check-in Location Recorded Yet!");
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Maps(
                                      latitudeIn,
                                      longitudeIn,
                                      "Check-in Location",
                                    ),
                                  ),
                                );
                              }
                            },
                            splashColor: Colors.white,
                            child: locationButton(context, "Check-In"),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Material(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8.0),
                          child: InkWell(
                            onTap: () {
                              if (latitudeOut == "" && longitudeOut == "") {
                                errorDialog(context,
                                    "No Check-Out Location Recorded Yet!");
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Maps(
                                      latitudeOut,
                                      longitudeOut,
                                      "Check-Out Location",
                                    ),
                                  ),
                                );
                              }
                            },
                            splashColor: Colors.white,
                            child: locationButton(context, "Check-Out"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget locationButton(BuildContext context, String text) {
  return Container(
    width: MediaQuery.of(context).size.width * .254,
    height: MediaQuery.of(context).size.height * .05,
    child: Center(
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyText2,
          children: [
            WidgetSpan(
              child: Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * .04,
              ),
            ),
            TextSpan(
              text: " $text",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * .03,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
