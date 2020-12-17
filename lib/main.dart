import 'package:calendar/CreateTask.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Task.dart';
import 'TaskDetails.dart';
import 'database.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  //Controllers
  AnimationController _animationController;
  CalendarController _calendarController;

  //Variables
  Map<DateTime, List> _events;
  List _selectedDayEvents;
  DateTime _selectedDay = DateTime.now();

  //Database instance
  final dbHelper = DatabaseHelper.instance;

  //Override methods
  @override
  void initState() {
    super.initState();

    _events = {};
    _selectedDayEvents = _events[DateTime.now()] ?? [];
    _calendarController = CalendarController();

    getEvents();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  //Methods

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedDay = day;
      _selectedDayEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          label: Text("Add a new task"),
          icon: Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30))),
                enableDrag: true,
                builder: (BuildContext cont) {
                  return (CreateTask(_selectedDay));
                }).then((value) => {
                  setState(() {
                    //This should not be the most efficient approach.
                    //Adding solely the event to _events could improve efficiency.
                    getEvents();
                    _calendarController.setSelectedDay(_selectedDay,
                        runCallback: true);
                  })
                });
          },
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildTableCalendar(),
            const SizedBox(height: 8.0),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepPurple,
        todayColor: Colors.deepPurpleAccent,
        markersColor: Colors.blueAccent,
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventList() {
    print("Building");
    return ListView(
      physics: BouncingScrollPhysics(),
      children: _selectedDayEvents
          .map(
            (task) => Dismissible(
              key: UniqueKey(),
              background: Container(color: Colors.red),
              onDismissed: (direction) {
                setState(() {
                  //Steeping removing, prevents from getting the database once again

                  //Removing from the events state
                  _events.remove(
                      DateTime.fromMillisecondsSinceEpoch(task.dateStart));
                  //Removing from the listView
                  _selectedDayEvents.remove(task);
                  //Removing from the database
                  dbHelper.delete(task);
                  String aux = task.name;
                  Fluttertoast.showToast(
                    msg: "$aux deleted",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 1,
                  );
                });
              },
              child: Hero(
                tag: task.id,
                child: Material(
                  child: GFListTile(
                    titleText: task.name,
                    padding: EdgeInsets.only(top: 0),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.description,
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              DateTime.fromMillisecondsSinceEpoch(
                                          task.dateStart)
                                      .hour
                                      .toString() +
                                  ":" +
                                  DateTime.fromMillisecondsSinceEpoch(
                                          task.dateStart)
                                      .minute
                                      .toString(),
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            //If the beginning date, is the same as the ending one,
                            //only show the first date.
                            Text(
                              task.dateStart == task.dateEnd
                                  ? ""
                                  : DateTime.fromMillisecondsSinceEpoch(
                                              task.dateEnd)
                                          .hour
                                          .toString() +
                                      ":" +
                                      DateTime.fromMillisecondsSinceEpoch(
                                              task.dateEnd)
                                          .minute
                                          .toString(),
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    enabled: true,
                    selected: false,
                    icon: IconButton(
                      icon: Icon(
                        task.dateStart > task.dateEnd || task.done
                            ? Icons.check_circle
                            : Icons.access_time_outlined,
                        color: task.dateStart > task.dateEnd || task.done
                            ? Colors.green
                            : Colors.deepOrange,
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

                        setState(() {});
                      },
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30))),
                        enableDrag: true,
                        builder: (BuildContext cont) {
                          return (TaskDetails(task));
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Map<DateTime, List<dynamic>> convertTaskToEvent(List<Task> tasks) {
    Map<DateTime, List<dynamic>> lisEvent = {};
    tasks.forEach((task) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(task.dateStart);
      bool found = false;
      List<Task> aux = [];
      if (lisEvent.isNotEmpty) {
        lisEvent.forEach((key, value) {
          if (key.year == date.year &&
              key.month == date.month &&
              key.day == date.day) {
            found = true;
            value.add(task);
            lisEvent[key] = value;
          }
        });
      }
      if (!found || lisEvent.isEmpty) {
        aux.add(task);
        lisEvent[date] = aux;
      }
    });
    return lisEvent;
  }

  void getEvents() {
    print("Fetching events...");
    dbHelper.queryAllRows().then(
          (tasks) => setState(() {
            _events = convertTaskToEvent(tasks);
          }),
        );
  }
}
