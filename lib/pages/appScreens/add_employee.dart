import 'package:auto_size_text/auto_size_text.dart';
import 'package:efs_new/Database/models/employee_model.dart';
import 'package:efs_new/Database/operations/employee_operations.dart';
import 'package:efs_new/pages/appScreens/team_list.dart';
import 'package:efs_new/widgets/dialog_widget.dart';
import 'package:efs_new/widgets/globals.dart';

import 'package:flutter/material.dart';

final employeeId = TextEditingController();
final employeeName = TextEditingController();
final designation = TextEditingController();
final department = TextEditingController();
final teamId = TextEditingController();
final _formKey = GlobalKey<FormState>();
EmployeeOperations employeeOperations = EmployeeOperations();

class AddEmployee extends StatefulWidget {
  const AddEmployee({Key key}) : super(key: key);

  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
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
          "Add Employee",
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          "Please fill all details",
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
                      children: [
                        Flexible(
                          child:
                          textField(context, employeeName, "Employee Name"),
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
                          child: textField(context, designation, "Designation"),
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
                          child: textField(context, department, "Department"),
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
                      children: [
                        saveData(
                          context,
                          Globals.teamName,
                          Globals.teamId,
                          Globals.deviceId,
                        )
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

Widget saveData(BuildContext context, String teamName, teamId, deviceId) {
  return GestureDetector(
    onTap: () {
      if (employeeId.text == "" ||
          employeeName.text == "" ||
          designation.text == "" ||
          department.text == "") {
        errorDialog(context, "Fill all fields!");
      } else {
        final employee = Employee(
          id: 0,
          employeeId: employeeId.text,
          employeeName: employeeName.text,
          department: department.text,
          designation: designation.text,
          image: "",
          teamId: teamId.toString(),
          status: "A",
          isTeamLead: "",
          username: "",
          password: "",
          teamName: teamName.toString(),
          isSync: "0",
          imageData: "",
        );
        var create = employeeOperations.createEmployee(employee);
        if (create != null) {
          successDialogOnly(context, "Employee Added!!");
          employeeId.clear();
          employeeName.clear();
          designation.clear();
          department.clear();
          Future.delayed(Duration(milliseconds: 1500), () {
            employeeId.clear();
            employeeName.clear();
            designation.clear();
            department.clear();
            int count = 0;
            Navigator.of(context).popUntil((_) => count++ >= 3);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TeamList(),
              ),
            );
          });
        } else {
          errorDialog(context, "Employee Not Added!!");
        }
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
        color: Colors.green[400],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Text(
          "Save Data",
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
