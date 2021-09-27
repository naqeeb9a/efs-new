import 'package:auto_size_text/auto_size_text.dart';
import 'package:efs_new/Database/models/employee_model.dart';
import 'package:efs_new/Database/operations/employee_operations.dart';
import 'package:efs_new/pages/appScreens/team_list.dart';
import 'package:efs_new/widgets/dialog_widget.dart';
import 'package:efs_new/widgets/globals.dart';
import 'package:efs_new/widgets/text_field.dart';
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
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
                      top: MediaQuery.of(context).size.height * .01,
                      bottom: MediaQuery.of(context).size.height * .04,
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
                      vertical: MediaQuery.of(context).size.height * .02,
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
                      vertical: MediaQuery.of(context).size.height * .02,
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
                      vertical: MediaQuery.of(context).size.height * .02,
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
                      vertical: MediaQuery.of(context).size.height * .02,
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
                      vertical: MediaQuery.of(context).size.height * .02,
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

Widget saveData(BuildContext context, String teamName, teamId, deviceId) {
  return Material(
    color: Colors.green[400],
    borderRadius: BorderRadius.circular(10.0),
    child: InkWell(
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
      splashColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * .5,
        height: MediaQuery.of(context).size.height * .07,
        child: Center(
          child: Text(
            "Save Data",
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
