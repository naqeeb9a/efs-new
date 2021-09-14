import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:efs_new/Database/operations/employee_operations.dart';
import 'package:efs_new/pages/appScreens/team_list.dart';
import 'package:efs_new/widgets/dialog_widget.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final employeeId = TextEditingController();
final _formKey = GlobalKey<FormState>();
EmployeeOperations employeeOperations = EmployeeOperations();

class DeleteEmployee extends StatefulWidget {
  const DeleteEmployee({Key key}) : super(key: key);

  @override
  _DeleteEmployeeState createState() => _DeleteEmployeeState();
}

class _DeleteEmployeeState extends State<DeleteEmployee> {
  bool isLoading = false;

  Future searchEmployee(BuildContext context, String id) async {
    return employeeOperations.searchEmployees(id).then((result) async {
      if (result.length > 0) {
        if (result[0]['isSync'].toString() == '1') {
          try {
            final net = await InternetAddress.lookup('example.com');
            if (net.isNotEmpty && net[0].rawAddress.isNotEmpty) {
              var response = await http.post(
                  Uri.parse(
                      "https://attendanceapp.genxmtech.com/api/removeEmployee"),
                  body: {
                    "employee_id": id.toString(),
                  });
              var responseBody = jsonDecode(response.body);

              if (responseBody['message'].toString() ==
                  "Member Deleted Successfully" ||
                  responseBody['message'].toString() ==
                      "Employee ID does not exists" ||
                  responseBody['message'].toString() ==
                      "Member Removed From Team ") {
                employeeOperations.deleteEmployee(id);
                successDialogOnly(context, "Employee Data Deleted!!");
                employeeId.clear();
                Future.delayed(Duration(milliseconds: 1500), () {
                  int count = 0;
                  employeeId.clear();
                  Navigator.of(context).popUntil((_) => count++ >= 3);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TeamList(),
                    ),
                  );
                });
              } else {
                errorDialog(
                    context, "Something went Wrong!!\nPlease Try Later!!");
              }
            }
          } on SocketException catch (_) {
            setState(() {
              isLoading = false;
            });
            errorDialog(context, "No Internet Connection!");
          }
        } else if (result[0]['isSync'].toString() == '0') {
          employeeOperations.deleteEmployee(id);
          successDialogOnly(context, "Employee Data Deleted!!");
          employeeId.clear();
          Future.delayed(Duration(milliseconds: 1500), () {
            employeeId.clear();
            int count = 0;
            Navigator.of(context).popUntil((_) => count++ >= 3);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TeamList(),
              ),
            );
          });
        }
      } else {
        errorDialog(context, "Employee not Exist!!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    final height = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        title: Text(
          "Delete Employee",
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
      body: Center(
        child: Container(
          width: width * .9,
          height: height * .8,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery
                        .of(context)
                        .size
                        .height * .01,
                    bottom: MediaQuery
                        .of(context)
                        .size
                        .height * .04,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        "Enter Employee Id to delete",
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
                    vertical: MediaQuery
                        .of(context)
                        .size
                        .height * .02,
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: textField(context, employeeId, "Employee Id"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery
                        .of(context)
                        .size
                        .height * .02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [deleteButton(context)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget deleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (employeeId.text == "") {
          errorDialog(context, "Enter Employee Id!");
        } else {
          searchEmployee(context, employeeId.text).toString();
        }
      },
      child: Container(
        width: MediaQuery
            .of(context)
            .size
            .width * .5,
        height: MediaQuery
            .of(context)
            .size
            .height * .07,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Text(
            "Delete Data",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: MediaQuery
                  .of(context)
                  .size
                  .width * .05,
            ),
          ),
        ),
      ),
    );
  }
}

//textField widget
Widget textField(BuildContext context, TextEditingController controller,
    String labelText) {
  return Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 1,
    decoration: BoxDecoration(
      color: Colors.white60,
      borderRadius: BorderRadius.circular(9),
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
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 14.0),
        errorStyle: TextStyle(
          fontSize: 15.0,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(9.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
          borderRadius: BorderRadius.circular(9.0),
        ),
        border: InputBorder.none,
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
        ),
      ),
    ),
  );
}
