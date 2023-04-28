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

class EventUpdate extends EventEvent {
  final Event event;
  final VoidCallback? onFinished;

  EventUpdate({required this.event, this.onFinished});

  @override
  List<Object?> get props => [event, onFinished];
}

class EventFetch extends EventEvent {
  final VoidCallback? onFinished;

  EventFetch({this.onFinished});

  @override
  List<Object?> get props => [onFinished];
}

class EventDelete extends EventEvent {
  final String eventId;
  final VoidCallback? onFinished;

  EventDelete({required this.eventId, this.onFinished});

  @override
  List<Object?> get props => [eventId, onFinished];
}
