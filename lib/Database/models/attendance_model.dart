class AttendanceData {
  int id;
  String employeeId;
  String teamId;
  String date;
  String timeIn;
  String timeOut;
  String longitudeIn;
  String latitudeIn;
  String longitudeOut;
  String latitudeOut;
  String attendanceImage;
  String syncStatus;
  String updateTime;

  AttendanceData({
    this.id,
    this.employeeId,
    this.teamId,
    this.date,
    this.timeIn,
    this.timeOut,
    this.longitudeIn,
    this.latitudeIn,
    this.longitudeOut,
    this.latitudeOut,
    this.attendanceImage,
    this.syncStatus,
    this.updateTime,
  });

  AttendanceData.fromMap(Map<String, dynamic> map) {
    this.id = map['id'] as int;
    this.employeeId = map['employeeId'] as String;
    this.teamId = map['teamId'] as String;
    this.date = map['date'] as String;
    this.timeIn = map['timeIn'] as String;
    this.timeOut = map['timeOut'] as String;
    this.longitudeIn = map['longitudeIn'] as String;
    this.latitudeIn = map['latitudeIn'] as String;
    this.longitudeOut = map['longitudeOut'] as String;
    this.latitudeOut = map['latitudeOut'] as String;
    this.attendanceImage = map['attendanceImage'] as String;
    this.syncStatus = map['syncStatus'] as String;
    this.syncStatus = map['updateTime'] as String;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'employeeId': employeeId,
      'teamId': teamId,
      'date': date,
      'timeIn': timeIn,
      'timeOut': timeOut,
      'longitudeIn': longitudeIn,
      'latitudeIn': latitudeIn,
      'longitudeOut': longitudeOut,
      'latitudeOut': latitudeOut,
      'attendanceImage': attendanceImage,
      'syncStatus': syncStatus,
      'updateTime': updateTime,
    };

    return map;
  }
}
