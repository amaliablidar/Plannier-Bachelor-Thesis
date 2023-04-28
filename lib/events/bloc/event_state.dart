part of 'event_bloc.dart';

@immutable
abstract class EventState extends Equatable {}

class EventLoaded extends EventState {
  final List<Event> events;
  final bool isLoading;
  final List<UserPlannier> guests;
  final Event? nextEvent;

  EventLoaded({
    required this.events,
    required this.isLoading,
    required this.guests,
    this.nextEvent,
  });

  EventLoaded copyWith(
          {List<Event>? events,
          bool? isLoading,
          List<UserPlannier>? guests,
          Event? nextEvent}) =>
      EventLoaded(
        events: events ?? this.events,
        isLoading: isLoading ?? this.isLoading,
        guests: guests ?? this.guests,
        nextEvent: nextEvent ?? this.nextEvent,
      );

  @override
  List<Object?> get props => [
        events,
        isLoading,
        guests,
        nextEvent,
      ];
}
