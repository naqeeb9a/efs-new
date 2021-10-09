import 'package:flutter/material.dart';

Widget textField(BuildContext context, TextEditingController controller,
    String labelText, bool obscureText) {
  return Container(
    width: MediaQuery.of(context).size.width * 1,
    decoration: BoxDecoration(
      color: Colors.white60,
      borderRadius: BorderRadius.circular(
        MediaQuery.of(context).size.width * .01,
      ),
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
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 14.0),
        errorStyle: TextStyle(
          fontSize: 15.0,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * .01,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * .01,
          ),
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
