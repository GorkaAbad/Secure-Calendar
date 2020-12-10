import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class CreateTask extends StatefulWidget {
  DateTime day;

  CreateTask(this.day);

  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Hero(
      tag: 1,
      child: Material(
        child: GFListTile(),
      ),
    ));
  }
}
