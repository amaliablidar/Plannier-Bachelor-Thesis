part of 'invitation_bloc.dart';

@immutable
abstract class InvitationEvent extends Equatable {}

class InvitationFetch extends InvitationEvent {
  final VoidCallback? onFinished;

  InvitationFetch({this.onFinished});

  @override
  List<Object?> get props => [onFinished];
}

class InvitationResponse extends InvitationEvent {
  final Invitation invitation;
  final VoidCallback? onFinished;

  InvitationResponse({required this.invitation, this.onFinished});

  @override
  List<Object?> get props => [invitation, onFinished];
}

class InvitationFilter extends InvitationEvent{
  final Response? responseToFilter;

  InvitationFilter({this.responseToFilter});

  @override
  List<Object?> get props => [responseToFilter];


}
