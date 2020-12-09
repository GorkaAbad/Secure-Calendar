import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:local_auth/local_auth.dart';
import 'Task.dart';
import 'package:getwidget/getwidget.dart';
import 'database.dart';
import 'TaskDetails.dart';

List<Task> lis = [];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Controllers
  CalendarController _controller;
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController2 = ScrollController();

  //Database
  final dbHelper = DatabaseHelper.instance;

  //Variables
  List<Widget> listTask = [];
  final color = 0xff30384c;
  bool isChecked = false;

  //Functions

  /*
  Gets every single task from the database and add it to the global variables "lis".
  Note that this process is done asynchronously, so it could happen not to have
  ready the task when booting the app.
   */
  void getTasksFromDB() {
    dbHelper.queryAllRows().then((tasks) => {
          tasks.forEach((task) {
            lis.add(task);
          }),
          getTask()
        });
  }

  void initialiseDB() {
    List<Task> lisIni = [
      Task(DateTime.now().millisecondsSinceEpoch, "name1", "description", 3, 4,
          "color", true),
      Task(DateTime.now().millisecondsSinceEpoch + 32, "name1", "description",
          3, 4, "color", true),
      Task(DateTime.now().millisecondsSinceEpoch + 2, "name1", "description", 3,
          4, "color", true),
      Task(DateTime.now().millisecondsSinceEpoch + 5, "name1", "description", 3,
          4, "color", true),
      Task(DateTime.now().millisecondsSinceEpoch + 6, "name1", "description", 3,
          4, "color", true),
      Task(DateTime.now().millisecondsSinceEpoch + 16, "name1", "description",
          3, 4, "color", true)
    ];

    //dbHelper.resetValues();

    /* lisIni.forEach((task) {
      dbHelper.insert(task);
    });*/
    getTasksFromDB();
  }

  /*
  Creates Widgets from the pre-loaded Task list and stores them at LisItem.
  After that values are dumped into lisTask, that keeps the state of them.
   */
  void getTask() {
    List<Widget> lisItem = [];

    lis.forEach((task) {
      IconData icon;
      MaterialColor colorIcon;

      if (task.dateStart > task.dateEnd || task.done) {
        icon = Icons.check_circle;
        colorIcon = Colors.green;
      } else {
        icon = Icons.access_time;
        colorIcon = Colors.deepOrange;
      }

      lisItem.add(Hero(
        tag: task.id,
        child: Material(
          child: GFListTile(
            titleText: task.name,
            padding: EdgeInsets.only(top: 0),
            subtitleText: task.description,
            enabled: true,
            selected: false,
            icon: IconButton(
              icon: Icon(
                icon,
                color: colorIcon,
                size: 25,
              ),
              onPressed: () {
                //Update database
                task.done = !task.done;
                dbHelper.update(task);
                Fluttertoast.showToast(
                  msg: "Updating state...",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 1,
                );
                setState(() {
                  getTask();
                });
              },
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => new TaskDetails(task)
              ));
            },
          ),
        ),
      ));
    });
    setState(() {
      listTask = lisItem;
    });
  }

  //Overrides
  @override
  void initState() {
    //TODO:
    //https://stackoverflow.com/questions/43877288/how-to-hide-android-statusbar-in-flutter
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    initialiseDB();
    _controller = CalendarController();
    _scrollController.addListener(() {
      //getTask();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  //https://github.com/flutter/flutter/issues/14842
  /*
  child: ListView.builder(
    padding: EdgeInsets.zero,
    itemBuilder: (context, index) {
        return Card(...);
    },
),
OR
Safe Area
   */

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TableCalendar(
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      color: Color(color),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Color(color),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Color(color),
                    )),
                daysOfWeekStyle: DaysOfWeekStyle(
                  //Mon, tue...
                  weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                  weekendStyle:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                calendarStyle: CalendarStyle(
                  weekdayStyle: TextStyle(fontWeight: FontWeight.normal),
                ),
                calendarController: _controller),
            Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Expanded(
              child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  controller: _scrollController2,
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      controller: _scrollController,
                      itemCount: listTask.length,
                      itemBuilder: (context, index) {
                        return listTask[index];
                      },
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
