import 'package:calendar/main.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:local_auth/local_auth.dart';
import 'Task.dart';

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
double _paddingTop = 20;

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

      lisItem.add(Container(
        padding: EdgeInsets.only(top: 20),
        child: Row(
          children: [
            InkWell(
              child: Icon(
                icon,
                color: colorIcon,
              ),
              onTap: () {
                setState(() {
                  task.done = !task.done;
                  task.markDone();
                  getTask();
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Task " + task.name,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                ),
                Text(
                  "Description of the task " + task.name,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                ),
              ],
            )
          ],
        ),
      ));

      setState(() {
        listTask = lisItem;
      });
    });
  }

  @override
  void initState() {
    super.initState();
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
              padding: EdgeInsets.only(top: _paddingTop),
            ),
            Expanded(
              child: GestureDetector(
                onPanUpdate: (tapInfo) {
                  print(tapInfo.localPosition.dy);
                  print(_paddingTop);
                  if (tapInfo.localPosition.dy < _paddingTop + 5 &&
                      tapInfo.localPosition.dy + 5 >= _paddingTop) {
                    setState(() {
                      if (tapInfo.localPosition.dy > 20 &&
                          tapInfo.globalPosition.dy <
                              MediaQuery.of(context).size.height * 0.965) {
                        _paddingTop = tapInfo.localPosition.dy;
                      }
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(left: 30),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50)),
                      color: Color(color)),
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 50),
                        child: Text(
                          "Today",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        padding: EdgeInsets.only(top: 85),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          controller: _scrollController,
                          itemCount: listTask.length,
                          itemBuilder: (context, index) {
                            return listTask[index];
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
