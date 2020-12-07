import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'Task.dart';

const String dbName = 'calendar';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  databaseExists().then((value) => {
        //If database exist then
        //Reset for testing purposes
        if (value)
          {
            //Delete
            resetValues(),
            //Create again
            getDatabase(),
            insertValues()
          }
        else
          {
            //Create
            getDatabase(),
            insertValues()
          }
      });

  getTask().then((value) => print(value));
}

//Future<List<Task>> task() async {
Future<List<Map<String, dynamic>>> getTask() async {
  final Database db = await getDatabase();

  final List<Map<String, dynamic>> maps = await db.query(dbName);

  return maps;
/*
    return List.generate(maps.length, (int i) => {
     Task(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        dateStart: maps[i]['dateStart'],
        dateEnd: maps[i]['dateEnd'],
        color: maps[i]['color'],
      );
  });
 */
}

Future<Database> getDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), dbName + '.db'),
    onCreate: (db, version) {
      return db.execute("CREATE TABLE " +
          dbName +
          " (id INTEGER PRIMARY KEY,name TEXT,description TEXT,dateStart INTEGER,dateEnd INTEGER,color TEXT)");
    },
    version: 1,
  );
}

Future<void> insertTask(Task task) async {
  final Database db = await getDatabase();
  await db.insert(dbName, task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

void insertValues() async {
  await insertTask(Task(
      DateTime.now().millisecondsSinceEpoch,
      "Task1",
      "Description of the task 1",
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
      "Red",
      true));
}

void resetValues() {
  getDatabasesPath()
      .then((value) => {File(join(value, dbName + '.db')).delete(), getTask()});
}

Future<bool> databaseExists() {
  return getDatabasesPath()
      .then((value) => File(join(value, dbName + '.db')).exists());
}
