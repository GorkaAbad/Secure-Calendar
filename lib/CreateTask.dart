import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Task.dart';
import 'database.dart';

class CreateTask extends StatefulWidget {
  DateTime day;

  CreateTask(this.day);

  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
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

  @override
  Widget build(BuildContext context) {
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
                validator: (value) =>
                    value.isEmpty ? 'This value must be filled' : null,
                onChanged: (name) => {taskName = name},
                decoration: InputDecoration(
                  labelText: 'Event name',
                  icon: Icon(Icons.calendar_today_rounded),
                ),
              ),
              TextFormField(
                validator: (value) =>
                    value.isEmpty ? 'This value must be filled' : null,
                onChanged: (des) => {description = des},
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
                      dateControllerEnd.text =
                          dateEnd.toString().substring(0, 16);
                    }
                  }
                },
              ),
              ButtonBar(children: [
                RaisedButton(
                  child: Text("Save"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.blue,
                  onPressed: () {
                    Task aux;
                    if (_formKey.currentState.validate()) {
                      aux = new Task(
                          DateTime.now().millisecondsSinceEpoch,
                          taskName,
                          description,
                          dateStart.millisecondsSinceEpoch,
                          dateEnd.millisecondsSinceEpoch,
                          "blue",
                          false);

                      dbHelper.insert(aux);

                      Fluttertoast.showToast(
                        msg: "Task added",
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                      );
                    }
                    Navigator.pop(context, aux);
                  },
                ),
              ]),
            ],
            mainAxisSize: MainAxisSize.min,
          ),
        ));
  }
}
