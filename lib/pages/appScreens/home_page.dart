import 'dart:async';


import 'package:efs_new/pages/appScreens/team_list.dart';
import 'package:efs_new/pages/appScreens/time_sheet.dart';
import 'package:efs_new/widgets/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attendance.dart';
import 'device_id.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences pref;
  SharedPreferences deviceid;
  SharedPreferences teamid;
  SharedPreferences teamname;

  var _loading = true;

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
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return _loading == true
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
                strokeWidth: 4,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Container(
                width: width * .8,
                height: height * .96,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height * .08),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/logo.jpeg",
                            scale: 1.4,
                          ),
                        ],
                      ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
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
                          child: Container(
                            width: MediaQuery.of(context).size.width * .4,
                            height: MediaQuery.of(context).size.height * .084,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                .04,
                                      ),
                                      child: Icon(
                                        Icons.logout,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                .08,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .05,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Version 2.0.0",
                          style: TextStyle(
                            fontSize: width * .038,
                            color: Color(0xffb1b1b1),
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
}

Widget buttonContainer(
    BuildContext context, String title, icon, dynamic page, int color) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => page),
      );
    },
    child: Container(
      width: MediaQuery.of(context).size.width * .66,
      height: MediaQuery.of(context).size.height * .084,
      decoration: BoxDecoration(
        color: Color(color),
        borderRadius: BorderRadius.circular(10.0),
      ),
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
  );
}
