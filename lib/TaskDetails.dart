import 'package:calendar/Task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'database.dart';

class TaskDetails extends StatefulWidget {
  Task task;

  TaskDetails(this.task);

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final dateControllerStart = TextEditingController();
  final dateControllerEnd = TextEditingController();

  String taskName;
  String description;
  DateTime dateStart = DateTime.now();
  DateTime dateEnd;
  Color color;

  //Database instance
  final dbHelper = DatabaseHelper.instance;

  final _formKey = GlobalKey<FormState>();

  _TaskDetailsState();

  @override
  Widget build(BuildContext context) {
    dateControllerStart.text =
        DateTime.fromMillisecondsSinceEpoch(this.widget.task.dateStart)
            .toString()
            .substring(0, 16);
    dateControllerEnd.text =
        DateTime.fromMillisecondsSinceEpoch(this.widget.task.dateEnd)
            .toString()
            .substring(0, 16);

    dateStart = DateTime.fromMillisecondsSinceEpoch(this.widget.task.dateStart);
    dateEnd = DateTime.fromMillisecondsSinceEpoch(this.widget.task.dateEnd);
    return Form(
        key: _formKey,
        child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 10,
                  indent: 150,
                  endIndent: 150,
                  thickness: 5,
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: this.widget.task.name,
                  validator: (value) =>
                      value.isEmpty ? 'This value must be filled' : null,
                  onChanged: (name) => {this.widget.task.name = name},
                  decoration: InputDecoration(
                    labelText: 'Event name',
                    icon: Icon(Icons.calendar_today_rounded),
                  ),
                ),
                TextFormField(
                  initialValue: this.widget.task.description,
                  validator: (value) => value.isEmpty ? value = '' : null,
                  onChanged: (des) => {this.widget.task.description = des},
                  decoration: InputDecoration(
                    labelText: 'Description',
                    icon: Icon(Icons.description_rounded),
                  ),
                ),
                TextFormField(
                  validator: (value) =>
                      value.isEmpty ? 'This value must be filled' : null,
                  decoration: InputDecoration(
                    labelText: 'Start date',
                    icon: Icon(Icons.today_rounded),
                  ),
                  controller: dateControllerStart,
                  onTap: () async {
                    DateTime date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      TimeOfDay time = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        dateStart = DateTime(date.year, date.month, date.day,
                            time.hour, time.minute);
                        this.widget.task.dateStart =
                            dateStart.millisecondsSinceEpoch;
                        dateControllerStart.text =
                            dateStart.toString().substring(0, 16);
                      }
                    }
                  },
                ),
                TextFormField(
                  validator: (value) =>
                      value.isEmpty ? 'This value must be filled' : null,
                  decoration: InputDecoration(
                    labelText: 'End date',
                    icon: Icon(Icons.today_rounded),
                  ),
                  controller: dateControllerEnd,
                  onTap: () async {
                    DateTime date = await showDatePicker(
                      context: context,
                      initialDate: dateStart,
                      firstDate: dateStart,
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      TimeOfDay time = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        dateEnd = DateTime(date.year, date.month, date.day,
                            time.hour, time.minute);
                        this.widget.task.dateEnd =
                            dateEnd.millisecondsSinceEpoch;

                        dateControllerEnd.text =
                            dateEnd.toString().substring(0, 16);
                      }
                    }
                  },
                ),
                ButtonBar(children: [
                  RaisedButton(
                    child: Text("Update"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.blue,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        this.widget.task.dateStart =
                            dateStart.millisecondsSinceEpoch;
                        this.widget.task.dateEnd =
                            dateEnd.millisecondsSinceEpoch;

                        dbHelper.update(this.widget.task);

                        Fluttertoast.showToast(
                          msg: "Task updated",
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 1,
                        );
                      }
                      Navigator.pop(context, this.widget.task);
                    },
                  ),
                ]),
              ],
              mainAxisSize: MainAxisSize.min,
            )));
  }
}
