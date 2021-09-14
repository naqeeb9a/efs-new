

import 'package:efs_new/Database/models/team_model.dart';

import '../db.dart';

final String tableName = "Team";
Team team;

class TeamOperations {
  TeamOperations teamOperations;

  final dbProvider = DBHelper.instance;

  createTeam(Team team) async {
    final db = await dbProvider.database;
    db.insert(tableName, team.toMap());
    return true;
  }

  Future<List> getTeam() async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> maps = await db.query(tableName);

    List team = [];

    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        team.add(maps[i]);
      }
    }
    return team;
  }

  Future<List> searchTeam(String keyword) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'teamId=?', whereArgs: [keyword]);
    List team = [];

    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        team.add(maps[i]);
      }
    }
    if (team.isEmpty) {}
    return team;
  }

  clearTeamDb() async {
    final db = await dbProvider.database;
    await db.delete(tableName);
  }
}
