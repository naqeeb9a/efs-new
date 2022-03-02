import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:efs_new/Database/operations/employee_operations.dart';
import 'package:efs_new/pages/appScreens/team_list.dart';
import 'package:efs_new/widgets/dialog_widget.dart';
import 'package:efs_new/widgets/text_field.dart';
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
                      "https://attend.efsme.com:4380/api/removeEmployee"),
                  body: {
                    "employee_id": id.toString(),
                  });
              var responseBody = jsonDecode(response.body);

              if (responseBody['message'].toString() == "Member Deleted Successfully" ||
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
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
                      top: MediaQuery.of(context).size.height * .01,
                      bottom: MediaQuery.of(context).size.height * .04,
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
                      vertical: MediaQuery.of(context).size.height * .02,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: textField(
                              context, employeeId, "Employee Id", false),
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
                      children: [deleteButton(context)],
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

  Widget deleteButton(BuildContext context) {
    return Material(
      color: Colors.red,
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: () {
          if (employeeId.text == "") {
            errorDialog(context, "Enter Employee Id!");
          } else {
            searchEmployee(context, employeeId.text).toString();
          }
        },
        splashColor: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * .5,
          height: MediaQuery.of(context).size.height * .07,
          child: Center(
            child: Text(
              "Delete Data",
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
}
