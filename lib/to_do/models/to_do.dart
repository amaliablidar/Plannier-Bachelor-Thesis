import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:plannier/to_do/models/task.dart';

class ToDo extends Equatable {
  final String? id;
  final String? eventId;
  final String? title;
  final DateTime? lastEdit;
  final List<Task> tasks;

  const ToDo(
      {this.id, this.eventId, this.lastEdit, required this.tasks, this.title});

  ToDo.fromJson(String this.id, Map<String, dynamic> json)
      : title = json['title'],
        lastEdit = json['lastEdit'] != null
            ? (json['lastEdit'] as Timestamp).toDate()
            : DateTime.now(),
        eventId = json['eventId'],
        tasks = List<Task>.from(
            json['tasks'].map((e) => Task.fromJson(e)).toList());

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventId'] = eventId;
    data['lastEdit'] = Timestamp.fromDate(DateTime.now());
    data['title'] = title;
    data['tasks'] = tasks.map((e) => e.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'ToDo{id: $id, title: $title, lastEdit: $lastEdit, eventId: $eventId, tasks: $tasks}';
  }

  ToDo copyWith({
    String? id,
    String? eventId,
    String? title,
    DateTime? lastEdit,
    List<Task>? tasks,
  }) =>
      ToDo(
          id: id ?? this.id,
          eventId: eventId ?? this.eventId,
          title: title ?? this.title,
          lastEdit: lastEdit ?? this.lastEdit,
          tasks: tasks ?? this.tasks);

  @override
  List<Object?> get props => [
        id,
        title,
        eventId,
        tasks,
        lastEdit,
      ];
}
