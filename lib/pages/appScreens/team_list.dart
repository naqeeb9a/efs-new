import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:efs_new/Database/models/employee_model.dart';
import 'package:efs_new/Database/operations/employee_operations.dart';
import 'package:efs_new/pages/API/api.dart';
import 'package:efs_new/pages/appScreens/register_face.dart';
import 'package:efs_new/widgets/dialog_widget.dart';
import 'package:efs_new/widgets/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_employee.dart';
import 'delete_employee.dart';

class TeamList extends StatefulWidget {
  const TeamList({Key key}) : super(key: key);

  @override
  _TeamListState createState() => _TeamListState();
}

class _TeamListState extends State<TeamList> {
  Future<List> employeeData, teamData;
  String syncStatus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    employeeData = EmployeeOperations().getAllEmployees();
  }

  Future getUpdatedEmployee() {
    return ApiData().fetchTeamEmployeesInfo(Globals.deviceId).then((result) {
      if (result != null) {
        for (var item in result) {
          EmployeeOperations()
              .searchEmployees(item['employee_id'])
              .then((result) {
            if (result.length > 0) {
            } else {
              final employee = Employee(
                id: 0,
                employeeId: item['employee_id'],
                employeeName: item['employee_name'],
                department: item['department'],
                designation: item['designation'],
                image: item['image'],
                teamId: item['team_id'],
                status: item['status'],
                isTeamLead: item['is_teamlead'].toString(),
                username: item['username'],
                password: item['password'],
                teamName: item['team_name'],
                isSync: "1",
                imageData: item['image_data'],
              );
              EmployeeOperations().createEmployee(employee);
            }
          });
        }
      }
      Future.delayed(Duration(milliseconds: 1500), () {
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TeamList(),
          ),
        );
      });
    });
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
              "image": allEmployeeData[i]["image"].toString(),
              "image_data": allEmployeeData[i]["imageData"].toString(),
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
      getUpdatedEmployee();
    } else if (syncStatus == "error") {
      errorDialogOnly(context, "Error!!\nCheck your Internet or Try Again");
      getUpdatedEmployee();
    } else if (syncStatus == "already") {
      successDialogOnly(context, "Data already Synced!!");
      getUpdatedEmployee();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: employeeData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            backgroundColor: Color(0xfff2f2f2),
            appBar: AppBar(
              title: Text(
                Globals.teamName,
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
                      syncAllEmployees();
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
                  height: height * .88,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: width * .94,
                            height: height * .78,
                            child: (snapshot.data as List).length > 0
                                ? ListView.builder(
                                    itemCount: (snapshot.data as List).length,
                                    itemBuilder: (context, i) {
                                      return cardContainer(
                                        context,
                                        (snapshot.data as List)[i]['employeeId']
                                            .toString(),
                                        (snapshot.data as List)[i]
                                                ['employeeName']
                                            .toString(),
                                        (snapshot.data as List)[i]
                                                ['designation']
                                            .toString(),
                                        (snapshot.data as List)[i]['department']
                                            .toString(),
                                        (snapshot.data as List)[i]['isTeamLead']
                                            .toString(),
                                        (snapshot.data as List)[i]['username']
                                            .toString(),
                                        (snapshot.data as List)[i]['password']
                                            .toString(),
                                        (snapshot.data as List)[i]['image']
                                            .toString(),
                                        (snapshot.data as List)[i]['status']
                                            .toString(),
                                        (snapshot.data as List)[i]['isSync']
                                            .toString(),
                                        (snapshot.data as List)[i]['imageData']
                                            .toString(),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text("No Employees to Show!"),
                                  ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: width * .94,
                        height: height * .1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                bottomButtons(
                                  context,
                                  "Add Employee",
                                  AddEmployee(),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                bottomButtons(
                                  context,
                                  "Delete Employee",
                                  DeleteEmployee(),
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
        return Scaffold(
          backgroundColor: Color(0xfff2f2f2),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

Widget cardContainer(
    BuildContext context,
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
    imageData) {
  Uint8List bytes = Base64Codec().decode(image);
  return Container(
    width: MediaQuery.of(context).size.width * .94,
    height: MediaQuery.of(context).size.height * .24,
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
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .24,
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
                      width: MediaQuery.of(context).size.width * .3,
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
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            "Employee Name: ",
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
                      width: MediaQuery.of(context).size.width * .3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            employeeName.toUpperCase(),
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
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            "Designation: ",
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
                      width: MediaQuery.of(context).size.width * .3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            designation.toString().toUpperCase(),
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
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            "Status: ",
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
                      width: MediaQuery.of(context).size.width * .3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            status,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    registerButton(
                        context,
                        employeeId,
                        employeeName,
                        designation,
                        department,
                        isTeamLead,
                        username,
                        password,
                        image,
                        status,
                        isSync,
                        imageData),
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

Widget bottomButtons(BuildContext context, String title, dynamic page) {
  return Material(
    color: Colors.black,
    borderRadius: BorderRadius.circular(8.0),
    child: InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => page),
        );
      },
      splashColor: Colors.white,
      child: Container(
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
      ),
    ),
  );
}

Widget registerButton(
  BuildContext context,
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
  imageData,
) {
  return Material(
    color: Color(0xff022b5e),
    borderRadius: BorderRadius.circular(10.0),
    child: InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RegisterFace(
              employeeId: employeeId,
              employeeName: employeeName,
              designation: designation,
              department: department,
              isTeamLead: isTeamLead,
              username: username,
              password: password,
              image: image,
              status: status,
              isSync: isSync,
              imageData: imageData,
            ),
          ),
        );
      },
      splashColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * .4,
        height: MediaQuery.of(context).size.height * .06,
        child: Center(
          child: Text(
            "Register",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * .05,
            ),
          ),
        ),
      ),
    ),
  );
}
