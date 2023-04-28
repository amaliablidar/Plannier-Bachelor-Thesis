part of 'invitation_bloc.dart';

@immutable
abstract class InvitationState extends Equatable {}

class InvitationLoaded extends InvitationState {
  final List<Invitation> invitations;
  final List<Event> invitationEvents;
  final bool isLoading;
  final bool arePending;

  InvitationLoaded(
      {required this.invitations,
      required this.isLoading,
      required this.invitationEvents,
      required this.arePending});

  InvitationLoaded copyWith(
          {List<Invitation>? invitations,
          bool? isLoading,
          List<Event>? invitationEvents,
          bool? arePending}) =>
      InvitationLoaded(
        invitations: invitations ?? this.invitations,
        isLoading: isLoading ?? this.isLoading,
        invitationEvents: invitationEvents ?? this.invitationEvents,
        arePending: arePending ?? this.arePending,
      );

  @override
  List<Object?> get props => [invitations, isLoading, invitationEvents, arePending];
}
