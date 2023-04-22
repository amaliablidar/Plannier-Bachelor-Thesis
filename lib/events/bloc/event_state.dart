part of 'event_bloc.dart';

@immutable
abstract class EventState extends Equatable {}

class EventLoaded extends EventState {
  final List<Event> events;
  final bool isLoading;

  EventLoaded({required this.events, required this.isLoading});

  EventLoaded copyWith({List<Event>? events, bool? isLoading}) => EventLoaded(
        events: events ?? this.events,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [events, isLoading];
}
