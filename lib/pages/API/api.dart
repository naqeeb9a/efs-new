import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

class ApiData {
  fetchTeamEmployeesInfo(String deviceId) async {
    var url =
        Uri.https('attend.efsme.com:4380', 'api/getEmployees/$deviceId');
    var response = await http.get(url);
    List<dynamic> employees = [];
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      for (int i = 0; i < jsonResponse['data'].length; i++) {
        employees.add(jsonResponse['data'][i]);
      }
      return employees;
    } else {
      return false;
    }
  }

  fetchTeamInfo(String deviceId) async {
    var url =
        Uri.https('attend.efsme.com:4380', 'api/getTeams/$deviceId');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse;
    }
  }
}
