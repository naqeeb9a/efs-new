import 'package:auto_size_text/auto_size_text.dart';
import 'package:efs_new/widgets/text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final employeeId = TextEditingController();
final password = TextEditingController();
final confirmPassword = TextEditingController();
final _formKey = GlobalKey<FormState>();

class ChangePassword extends StatefulWidget {
  final String name;

  ChangePassword({this.name});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
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
        child: Container(
          width: MediaQuery.of(context).size.width * .9,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .06,
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
                        child: textField(context, password, "New Password"),
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
                            context, confirmPassword, "Confirm Password"),
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
