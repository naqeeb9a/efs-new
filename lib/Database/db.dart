import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper.privateConstructor();

  static final DBHelper instance = DBHelper.privateConstructor();

  static Database _database;

  final _databaseName = 'EFS';
  final _databaseVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: onCreate);
  }

  Future onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE Employee ( 
          id INTEGER PRIMARY KEY AUTOINCREMENT,
                    employeeId STRING NOT NULL,
                    employeeName STRING NOT NULL,
                    department STRING NOT NULL,
                    designation STRING NOT NULL,
                    image STRING,
                    teamId STRING NOT NULL,
                    status STRING,
                    isTeamLead STRING,
                    username STRING,
                    password STRING,
                    teamName STRING NOT NULL,
                    isSync STRING NULL,
                    imageData STRING NULL    
          )
''');

    await db.execute('''
        CREATE TABLE Team ( 
                id INTEGER,
                teamId STRING,
                employeeId STRING,
                teamName STRING,
                teamLocation STRING,
                teamLeadId STRING,
                deviceId STRING,
                groupId STRING,
                groupName STRING,
                status STRING
          )
    ''');

    await db.execute('''
        CREATE TABLE Attendance ( 
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                employeeId STRING NOT NULL,
                teamId STRING NULL,
                date STRING NULL,
                timeIn STRING NULL,
                timeOut STRING NULL,
                longitudeIn STRING NULL,
                latitudeIn STRING NULL,
                longitudeOut STRING NULL,
                latitudeOut STRING NULL,
                attendanceImage STRING NULL,
                syncStatus STRING NULL,
                updateTime STRING NULL,
                differenceTime STRING NULL
          )
    ''');
  }
}
