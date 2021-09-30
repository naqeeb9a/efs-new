import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:efs_new/Database/operations/employee_operations.dart';
import 'package:efs_new/widgets/dialog_widget.dart';
import 'package:efs_new/widgets/text_field.dart' as fields;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final employeeId = TextEditingController();
final password = TextEditingController();
final oldPassword = TextEditingController();
final confirmPassword = TextEditingController();
final _formKey = GlobalKey<FormState>();
bool isLoading = false;
EmployeeOperations employeeOperations = EmployeeOperations();

class ChangePassword extends StatefulWidget {
  final String name;

  ChangePassword({this.name});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  Future getData(String employeeId) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.width * .054,
          ),
        ),
        iconTheme: IconThemeData(
          color: Color(0xff022b5e),
        ),
        backgroundColor: Color(0xfff2f2f2),
        elevation: 4.0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * .9,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * .06,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            "Enter your Employee Id and New Password",
                            style: TextStyle(
                              color: Color(0xff022b5e),
                              fontSize: MediaQuery.of(context).size.width * .05,
                            ),
                            maxLines: 1,
                          ),
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
                          child: fields.textField(
                              context, employeeId, "Employee Id", false),
                        ),
                      ],
                    ),
                  ),
                  widget.name.toString().contains("Change")
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height * .02,
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                child: fields.textField(
                                    context, oldPassword, "Old Password", true),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: 0.0,
                        ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .02,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: fields.textField(
                              context, password, "New Password", true),
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
                          child: fields.textField(context, confirmPassword,
                              "Confirm Password", true),
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
                        changeButton(context, widget.name.toString()),
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

  Widget changeButton(BuildContext context, name) {
    return isLoading == false
        ? Material(
            color: Color(0xff022b5e),
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width * .03,
            ),
            child: name.toString().contains("Change")
                ? InkWell(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      if (employeeId.text.toString().isNotEmpty &&
                          password.text.toString().isNotEmpty &&
                          oldPassword.text.toString().isNotEmpty &&
                          confirmPassword.text.toString().isNotEmpty) {
                        String tempPassword = "";
                        await employeeOperations
                            .getSpecificEmployee(
                              employeeId.text.toString(),
                            )
                            .then(
                              (value) => {
                                tempPassword = value[0]['password'].toString(),
                              },
                            );
                        if (oldPassword.text.toString() ==
                            tempPassword.toString()) {
                          if (int.parse(password.text
                                  .toString()
                                  .compareTo(confirmPassword.text.toString())
                                  .toString()) ==
                              0) {
                            try {
                              final net =
                                  await InternetAddress.lookup('example.com');
                              if (net.isNotEmpty &&
                                  net[0].rawAddress.isNotEmpty) {
                                var response = await http.post(
                                    Uri.parse(
                                        "https://attendanceapp.genxmtech.com/api/changePassword"),
                                    body: {
                                      "employee_id": employeeId.text.toString(),
                                      "password": password.text.toString(),
                                    });
                                if (response.statusCode == 200) {
                                  employeeOperations.updatePassword(
                                      employeeId.text.toString(),
                                      password.text.toString());

                                  successDialogOnly(context,
                                      "Your Password Changed Successfully!!");
                                  Future.delayed(Duration(milliseconds: 1000),
                                      () {
                                    int count = 0;
                                    Navigator.of(context)
                                        .popUntil((_) => count++ >= 2);
                                    employeeId.clear();
                                    oldPassword.clear();
                                    password.clear();
                                    confirmPassword.clear();
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                }
                              }
                            } on SocketException catch (_) {
                              errorDialog(context, "No Internet Connection!!");
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            errorDialog(context, "Password Not Matched!!");
                          }
                        } else {
                          errorDialog(context, "Old Password not Matched!!");
                          setState(() {
                            isLoading = false;
                          });
                        }
                      } else {
                        errorDialog(context, "First fill all fields!!");
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    splashColor: Colors.white,
                    child: Container(
                      width: MediaQuery.of(context).size.width * .5,
                      height: MediaQuery.of(context).size.height * .07,
                      child: Center(
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      if (employeeId.text.toString().isNotEmpty &&
                          password.text.toString().isNotEmpty &&
                          confirmPassword.text.toString().isNotEmpty) {
                        if (int.parse(password.text
                                .toString()
                                .compareTo(confirmPassword.text.toString())
                                .toString()) ==
                            0) {
                          try {
                            final net =
                                await InternetAddress.lookup('example.com');
                            if (net.isNotEmpty &&
                                net[0].rawAddress.isNotEmpty) {
                              var response = await http.post(
                                  Uri.parse(
                                      "https://attendanceapp.genxmtech.com/api/changePassword"),
                                  body: {
                                    "employee_id": employeeId.text.toString(),
                                    "password": password.text.toString(),
                                  });
                              if (response.statusCode == 200) {
                                successDialogOnly(context,
                                    "Your Password Changed Successfully!!");
                                Future.delayed(Duration(milliseconds: 1000),
                                    () {
                                  int count = 0;
                                  Navigator.of(context)
                                      .popUntil((_) => count++ >= 3);
                                  employeeId.clear();
                                  password.clear();
                                  confirmPassword.clear();
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              }
                            }
                          } on SocketException catch (_) {
                            errorDialog(context, "No Internet Connection!!");
                          }
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                          errorDialog(context, "Password Not Matched!!");
                        }
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        errorDialog(context, "First fill all fields!!");
                      }
                    },
                    splashColor: Colors.white,
                    child: Container(
                      width: MediaQuery.of(context).size.width * .5,
                      height: MediaQuery.of(context).size.height * .07,
                      child: Center(
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
