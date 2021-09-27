import 'package:efs_new/Database/models/employee_model.dart';
import 'package:efs_new/Database/models/team_model.dart';
import 'package:efs_new/Database/operations/employee_operations.dart';
import 'package:efs_new/Database/operations/team_operations.dart';
import 'package:efs_new/pages/API/api.dart';
import 'package:efs_new/pages/appScreens/change_password.dart';
import 'package:efs_new/widgets/dialog_widget.dart';
import 'package:efs_new/widgets/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

final username = TextEditingController();
final password = TextEditingController();
final _formKey = GlobalKey<FormState>();

dynamic sharedTeamId, sharedTeamName;

save() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  SharedPreferences teamid = await SharedPreferences.getInstance();
  SharedPreferences teamname = await SharedPreferences.getInstance();
  pref.setString("token", username.text);
  teamid.setString("teamid", sharedTeamId);
  teamname.setString('teamname', sharedTeamName);
}

EmployeeOperations employeeOperations = EmployeeOperations();
TeamOperations teamOperations = TeamOperations();

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  List<dynamic> employees, teams;
  bool loginCheck = true, employeeCheck = false, teamCheck = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    teams = [];
    employees = [];

    ApiData().fetchTeamInfo(Globals.deviceId).then((result) {
      if (result != null) {
        for (var item in result) {
          teams.add(item);
          teamOperations.searchTeam(item['team_id'].toString()).then((result) {
            if (result.length > 0) {
            } else {
              final team = Team(
                id: int.parse(item['id'].toString()),
                teamId: item['team_id'].toString(),
                employeeId: item['employee_ids'],
                teamName: item['team_name'],
                teamLocation: item['team_location'],
                teamLeadId: item['team_lead_id'],
                deviceId: item['device_id'],
                groupId: item['group_id'] == null ? "" : item['group_id'],
                groupName: item['group_name'] == null ? "" : item['group_name'],
                status: item['status'],
              );
              teamOperations.createTeam(team);
            }
          });
        }
      }
    });

    ApiData().fetchTeamEmployeesInfo(Globals.deviceId).then((result) {
      if (result != null) {
        for (var item in result) {
          employees.add(item);
          employeeOperations
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
                image: item['image'] == "1.jpg" ? "" : item['image'],
                teamId: item['team_id'],
                status: item['status'],
                isTeamLead: item['is_teamlead'].toString(),
                username: item['username'],
                password: item['password'],
                teamName: item['team_name'],
                isSync: "1",
                imageData: "",
              );
              employeeOperations.createEmployee(employee);
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                width: width * .8,
                height: height * .8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/logo.jpeg",
                          scale: 1,
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * .14,
                        bottom: height * .01,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: width * .08,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Hi there! Nice to see you again",
                          style: TextStyle(
                            fontSize: width * .046,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * .05,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Username",
                            style: TextStyle(
                              fontSize: width * .04,
                              color: Color(0xff022b5e),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * .01,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child:
                                textField(context, username, "Username", false),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * .03,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Password",
                            style: TextStyle(
                              fontSize: width * .04,
                              color: Color(0xff022b5e),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * .01,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child:
                                textField(context, password, "Password", true),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: height * .02,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChangePassword(
                                    name: "Forgot Password",
                                  ),
                                ),
                              );
                            },
                            splashColor: Color(0xff022b5e),
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: width * .04,
                                color: Color(0xff022b5e),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * .02,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            color: Color(0xff022b5e),
                            borderRadius: BorderRadius.circular(8.0),
                            child: InkWell(
                              onTap: () {
                                for (int i = 0; i < employees.length; i++) {
                                  if (employees[i]['is_teamlead'] == 1 &&
                                      employees[i]['username'] ==
                                          username.text &&
                                      employees[i]['password'] ==
                                          password.text) {
                                    sharedTeamId = employees[0]['team_id'];
                                    sharedTeamName = employees[0]['team_name'];
                                    loginCheck = true;
                                    save();
                                    int count = 0;
                                    Navigator.popUntil(context, (route) {
                                      return count++ == 2;
                                    });
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(),
                                      ),
                                    );
                                    username.clear();
                                    password.clear();
                                    break;
                                  } else {
                                    loginCheck = false;
                                  }
                                }
                                if (loginCheck == false) {
                                  errorDialog(context,
                                      "Username or Password Not Matched!!");
                                }
                              },
                              splashColor: Colors.white,
                              child: Container(
                                width: width * .7,
                                height: height * .07,
                                child: Center(
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: width * .054,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
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
        ),
      ),
    );
  }
}

//textField widget
Widget textField(BuildContext context, TextEditingController controller,
    String hintText, bool obscureText) {
  return Container(
    width: MediaQuery.of(context).size.width * 1,
    decoration: BoxDecoration(
      color: Colors.white,
    ),
    child: TextFormField(
      initialValue: null,
      autocorrect: true,
      controller: controller,
      validator: (query) {
        if (query.isEmpty) {
          return 'Error';
        } else {
          return null;
        }
      },
      obscureText: obscureText,
      keyboardAppearance: Brightness.dark,
      keyboardType: TextInputType.name,
      style: TextStyle(
        color: Colors.black,
        fontSize: 15.0,
        decoration: TextDecoration.none,
      ),
      textInputAction: TextInputAction.next,
      cursorColor: Colors.black,
      cursorWidth: 2.0,
      cursorHeight: 26.0,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
        errorStyle: TextStyle(
          fontSize: 15.0,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(0.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
          borderRadius: BorderRadius.circular(0.0),
        ),
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Color(0xffaeaeae),
          fontSize: 16.0,
        ),
      ),
    ),
  );
}
