part of 'to_do_bloc.dart';

@immutable
abstract class ToDoState extends Equatable {}

class ToDoLoaded extends ToDoState {
  final List<ToDo> toDo;
  final bool isLoading;

  ToDoLoaded({required this.toDo, required this.isLoading});

  ToDoLoaded copyWith({List<ToDo>? toDo, bool? isLoading}) => ToDoLoaded(
    toDo: toDo ?? this.toDo,
    isLoading: isLoading ?? this.isLoading,
  );

  @override
  List<Object?> get props => [toDo, isLoading];
}
