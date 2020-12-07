class Task {
  final int id;
  String name;
  String description;
  int dateStart;
  int dateEnd;
  String color;
  bool done;

  Task(this.id, this.name, this.description, this.dateStart, this.dateEnd,
      this.color, this.done);

  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      data['id'],
      data['name'],
      data['description'],
      data['dateStart'],
      data['dateEnd'],
      data['color'],
      data['done'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "dateStart": dateStart,
      "dateEnd": dateEnd,
      "color": color,
      "done": done
    };
  }

  void markDone() {
    //TODO: Save the new state to the database
  }
}
