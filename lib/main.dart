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
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          heroTag: 1,
          onPressed: () {
            print(_selectedDay.day);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => new CreateTask(_selectedDay),)
            );
          },
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // Switch out 2 lines below to play with TableCalendar's settings
            //-----------------------
            _buildTableCalendar(),
            // _buildTableCalendarWithBuilders(),
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
    return ListView(
      physics: BouncingScrollPhysics(),
      children: _selectedDayEvents
          .map((task) => Hero(
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => new TaskDetails(task)));
                    },
                  ),
                ),
              ))
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
