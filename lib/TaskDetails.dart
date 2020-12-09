import 'package:calendar/Task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class TaskDetails extends StatefulWidget{
  Task task;

  TaskDetails(this.task);

  @override
  _TaskDetailsState createState() => _TaskDetailsState();

}

class _TaskDetailsState extends State<TaskDetails> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Hero(
          tag: widget.task.id,
          child: Material(
            child: GFListTile(
              titleText: widget.task.name,
              subtitleText: widget.task.description,
            ),
          ),
        )
    );
  }
}