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

  ToDo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        lastEdit = json['lastEdit'] != null
            ? (json['lastEdit'] as Timestamp).toDate()
            : DateTime.now(),
        eventId = json['eventId'],
        tasks = List<Task>.from(
            json['tasks'].map((e) => Task.fromJson(e)).toList());

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
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

  @override
  List<Object?> get props => [
        id,
        title,
        eventId,
        tasks,
        lastEdit,
      ];
}
