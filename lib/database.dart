import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'Task.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = 'databaseCalendar.db';
  static final _databaseVersion = 1;

  static final table = 'calendar';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnDescription = 'description';
  static final columnDateStart = 'dateStart';
  static final columnDateEnd = 'dateEnd';
  static final columnColor = 'color';
  static final columnDone = 'done';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table ( 
      $columnId INTEGER PRIMARY KEY,$columnName TEXT,
      $columnDescription TEXT,$columnDateStart INTEGER,
      $columnDateEnd INTEGER,$columnColor TEXT,
      $columnDone INTEGER)
    ''');
  }

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Task task) async {
    Database db = await instance.database;
    return await db.insert(table, task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Task>> queryAllRows() async {
    Database db = await instance.database;
    List<Task> tasks = [];
    List<Map<String, dynamic>> lis = await db.query(table);
    lis.forEach((element) {
      tasks.add(Task.fromMap(element));
    });
    return tasks;
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Task task) async {
    Database db = await instance.database;
    Map<String, dynamic> row = task.toMap();
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(Task task) async {
    Database db = await instance.database;
    int id = task.id;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  void resetValues() {
    getDatabasesPath().then((value) => {
          File(join(value, _databaseName)).delete(),
        });
  }
}

/*
class DatabaseHelper {

  DatabaseHelper();

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    databaseExists().then((value) =>
    {
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
        DateTime
            .now()
            .millisecondsSinceEpoch,
        "Task1",
        "Description of the task 1",
        DateTime
            .now()
            .millisecondsSinceEpoch,
        DateTime
            .now()
            .millisecondsSinceEpoch,
        "Red",
        true));
  }

  void resetValues() {
    getDatabasesPath()
        .then((value) =>
    {
      File(join(value, dbName + '.db')).delete(),
      getTask()
    });
  }

  Future<bool> databaseExists() {
    return getDatabasesPath()
        .then((value) => File(join(value, dbName + '.db')).exists());
  }

}*/
