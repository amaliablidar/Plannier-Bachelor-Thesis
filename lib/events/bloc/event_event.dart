part of 'event_bloc.dart';

@immutable
abstract class EventEvent extends Equatable {}

class EventAdd extends EventEvent {
  final Event event;
  final VoidCallback? onFinished;

  EventAdd({required this.event, this.onFinished});

  @override
  List<Object?> get props => [event, onFinished];

}

class EventFetch extends EventEvent{
  @override
  List<Object?> get props => [];
}
