part of 'to_do_bloc.dart';

@immutable
abstract class ToDoEvent extends Equatable{}

class ToDoFetch extends ToDoEvent {
  final VoidCallback? onFinished;

  ToDoFetch({this.onFinished});
  @override
  List<Object?> get props => [onFinished];

}

class ToDoAdd extends ToDoEvent{
  final ToDo toDo;
  final VoidCallback? onFinished;

  ToDoAdd({required this.toDo, this.onFinished});

  @override
  List<Object?> get props => [toDo, onFinished];
}

class ToDoUpdate extends ToDoEvent{
  final ToDo toDo;
  final VoidCallback? onFinished;

  ToDoUpdate({required this.toDo, this.onFinished});

  @override
  List<Object?> get props => [toDo, onFinished];
}
class ToDoDelete extends ToDoEvent{
  final String toDoId;
  final VoidCallback? onFinished;

  ToDoDelete({required this.toDoId, this.onFinished});

  @override
  List<Object?> get props => [toDoId, onFinished];
}

