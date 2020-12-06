import 'dart:ffi';

import 'package:sqflite/sqflite.dart';

import 'database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
  final color = 0xff30384c;

  double heightCalculation() {
    return 10.0;
  }

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void aa() async{
    bool canCheckBiometrics = await LocalAuthentication().canCheckBiometrics;
    print(canCheckBiometrics);
    List<BiometricType> availableBiometrics =
    await LocalAuthentication().getAvailableBiometrics();
    print(availableBiometrics);

  }
  
  @override
  Widget build(BuildContext context) {
    final LocalAuthentication _localAuthentication = LocalAuthentication();
    print("sddasd");
    aa();
    return SafeArea( //Prevents notch issues
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TableCalendar(
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(
                          color: Color(color), fontWeight: FontWeight.bold)),
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
              SizedBox(
                height: heightCalculation(), //Depend on a parameter
              ), // Let some space after the calendar
              Container(
                  padding: EdgeInsets.only(left: 30),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50)),
                      color: Color(color)),
                  child: Stack(
                    children: <Widget>[],
                  )),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
          onPressed: () {

          },
        ),
      ),
    );
  }
}
