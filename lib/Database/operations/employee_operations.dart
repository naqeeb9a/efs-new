import 'package:efs_new/Database/models/employee_model.dart';

import '../db.dart';

final String tableName = "Employee";

class EmployeeOperations {
  EmployeeOperations employeeOperations;

  final dbProvider = DBHelper.instance;

  createEmployee(Employee employee) async {
    final db = await dbProvider.database;
    db.insert(tableName, employee.toMap());
    return true;
  }

  updateEmployee(String id, Employee employee) async {
    final db = await dbProvider.database;
    db.update(tableName, employee.toMap(),
        where: "employeeId=?", whereArgs: [id]);
  }

  updatePassword(String id, String password) async {
    final db = await dbProvider.database;
    int updateCount = await db.rawUpdate('''
    UPDATE $tableName 
    SET password = ?
    WHERE employeeId = ?
    ''', [password, id]);

    print(updateCount);
  }

  deleteEmployee(String id) async {
    final db = await dbProvider.database;
    await db.delete(
      tableName,
      where: 'employeeId=?',
      whereArgs: [id],
    );
  }

  clearEmployeeDb() async {
    final db = await dbProvider.database;
    await db.delete(tableName);
  }

  Future<List> getAllEmployees() async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> maps = await db.query(tableName);
    List employees = [];

    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        employees.add(maps[i]);
      }
    }
    if (employees.isEmpty) {}
    return employees;
  }

  Future<List> searchEmployees(String keyword) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'employeeId=?', whereArgs: [keyword]);
    List employees = [];

    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        employees.add(maps[i]);
      }
    }
    if (employees.isEmpty) {}
    return employees;
  }
}
