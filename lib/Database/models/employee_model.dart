class Employee {
  int id;
  String employeeId;
  String employeeName;
  String department;
  String designation;
  String image;
  String teamId;
  String status;
  String isTeamLead;
  String username;
  String password;
  String teamName;
  String isSync;
  String imageData;

  Employee({
    this.id,
    this.employeeId,
    this.employeeName,
    this.department,
    this.designation,
    this.image,
    this.teamId,
    this.status,
    this.isTeamLead,
    this.username,
    this.password,
    this.teamName,
    this.isSync,
    this.imageData,
  });

  Employee.fromMap(Map<String, dynamic> map) {
    this.id = map['id'] as int;
    this.employeeId = map['employeeId'] as String;
    this.employeeName = map['employeeName'] as String;
    this.department = map['department'] as String;
    this.designation = map['designation'] as String;
    this.image = map['image'] as String;
    this.teamId = map['teamId'] as String;
    this.status = map['status'] as String;
    this.isTeamLead = map['isTeamLead'] as String;
    this.username = map['username'] as String;
    this.password = map['password'] as String;
    this.teamName = map['teamName'] as String;
    this.isSync = map['isSync'] as String;
    this.imageData = map['imageData'] as String;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'employeeId': employeeId,
      'employeeName': employeeName,
      'department': department,
      'designation': designation,
      'image': image,
      'teamId': teamId,
      'status': status,
      'isTeamLead': isTeamLead,
      'username': username,
      'password': password,
      'teamName': teamName,
      'isSync': isSync,
      'imageData': imageData,
    };

    return map;
  }
}
