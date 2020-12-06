class Task {
  final int id;
  final String name;
  final String description;
  final int dateStart;
  final int dateEnd;
  final String color;

  Task(this.id, this.name, this.description, this.dateStart, this.dateEnd,
      this.color);

  factory Task.fromMap(Map<String, dynamic> data){
    return Task(
        data['id'],
        data['name'],
        data['description'],
        data['dateStart'],
        data['dateEnd'],
        data['color']
    );
  }

  Map<String, dynamic> toMap() {
    return{
      "id": id,
      "name": name,
      "description": description,
      "dateStart": dateStart,
      "dateEnd": dateEnd,
      "color": color
    };
  }
}