import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String? name;
  final bool? done;

  const Task({required this.name, required this.done});

  Task.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        done = json['done'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['done'] = done;
    return data;
  }


  @override
  String toString() {
    return 'Task{name: $name, done: $done}';
  }

  @override
  List<Object?> get props => [name, done];
}
