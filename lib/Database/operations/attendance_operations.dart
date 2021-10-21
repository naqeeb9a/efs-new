import 'package:efs_new/Database/models/attendance_model.dart';

import '../db.dart';

final String tableName = "Attendance";
AttendanceData attendanceData;

class AttendanceOperations {
  AttendanceOperations attendanceOperations;

  final dbProvider = DBHelper.instance;

  createAttendance(AttendanceData attendanceData) async {
    final db = await dbProvider.database;
    db.insert(tableName, attendanceData.toMap());
    return true;
  }

  Future<List> getAttendance() async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> maps = await db.query(tableName);

    List attendance = [];

    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        attendance.add(maps[i]);
      }
    }
    return attendance;
  }

  Future<List> getSpecificAttendance(String employeeId, String date) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> maps = await db.query(
      '$tableName',
      where: "employeeId=? and date=?",
      whereArgs: [employeeId, date],
    );

    List attendance = [];

    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        attendance.insert(0, maps[i]);
      }
    }
    return attendance;
  }

  Future<List> getAttendanceByOrder() async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
    );

    List attendance = [];

    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        attendance.insert(0, maps[i]);
      }
    }
    return attendance;
  }

  Future<List> searchAttendance(String keyword) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'employeeId=?', whereArgs: [keyword]);
    List attendance = [];

    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        attendance.insert(0, maps[i]);
      }
    }
    if (attendance.isEmpty) {}
    return attendance;
  }

  updateAttendance(int id, AttendanceData attendanceData) async {
    final db = await dbProvider.database;
    db.update(tableName, attendanceData.toMap(),
        where: "id=?", whereArgs: [id]);
  }

  clearAttendanceDb() async {
    final db = await dbProvider.database;
    await db.delete(tableName);
  }
}
