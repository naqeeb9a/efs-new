class Team {
  int id;
  String teamId;
  String employeeId;
  String teamName;
  String teamLocation;
  String teamLeadId;
  String deviceId;
  String groupId;
  String groupName;
  String status;

  Team({
    this.id,
    this.teamId,
    this.employeeId,
    this.teamName,
    this.teamLocation,
    this.teamLeadId,
    this.deviceId,
    this.groupId,
    this.groupName,
    this.status,
  });

  Team.fromMap(Map<String, dynamic> map) {
    this.id = map['id'] as int;
    this.teamId = map['teamId'] as String;
    this.employeeId = map['employeeId'] as String;
    this.teamName = map['teamName'] as String;
    this.teamLocation = map['teamLocation'] as String;
    this.teamLeadId = map['teamLeadId'] as String;
    this.deviceId = map['deviceId'] as String;
    this.groupId = map['groupId'] as String;
    this.groupName = map['groupName'] as String;
    this.status = map['status'] as String;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'teamId': teamId,
      'employeeId': employeeId,
      'teamName': teamName,
      'teamLocation': teamLocation,
      'teamLeadId': teamLeadId,
      'deviceId': deviceId,
      'groupId': groupId,
      'groupName': groupName,
      'status': status,
    };

    return map;
  }
}
