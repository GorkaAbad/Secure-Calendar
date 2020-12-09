import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:local_auth/local_auth.dart';
import 'Task.dart';
import 'package:getwidget/getwidget.dart';
import 'database.dart';

List<Task> lis = [
  Task(3, "name1", "description", 3, 4, "color", true),
  Task(3, "name", "description", 3, 4, "color", false),
  Task(3, "name", "description", 3, 4, "color", true),
  Task(3, "name", "description", 3, 4, "color", true),
  Task(3, "name", "description", 3, 4, "color", true),
  Task(3, "name", "description", 3, 4, "color", false),
  Task(3, "name", "description", 3, 4, "color", true),
  Task(3, "name", "description", 3, 4, "color", true),
  Task(3, "name", "description", 3, 4, "color", true),
  Task(3, "name", "description", 3, 4, "color", true),
];

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
  CalendarController _controller;
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  final dbHelper = DatabaseHelper.instance;

  final color = 0xff30384c;

  List<Widget> listTask = [];

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

      lisItem.add(GFListTile(
        titleText: 'Title ' + task.name,
        subtitleText: 'Lorem ipsum dolor sit amet, consectetur adipiscing',
        enabled: false,
        selected: false,
        icon: IconButton(
          icon: Icon(
            icon,
            color: colorIcon,
            size: 25,
          ),
          onPressed: () {
            Fluttertoast.showToast(
              msg: "Updating state...",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
            );
            setState(() {
              //Update database
              task.done = !task.done;
              task.markDone();
              getTask();
            });
          },
        ),
        onTap: () {},
      ));
      setState(() {
        listTask = lisItem;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    print("Init");
    getTask();
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
  bool isChecked = false;
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
