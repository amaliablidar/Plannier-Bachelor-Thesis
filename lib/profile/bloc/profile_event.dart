part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent extends Equatable {}

class ProfileUpdate extends ProfileEvent {
  final UserPlannier user;
  final VoidCallback? onFinished;

   ProfileUpdate({required this.user, this.onFinished});

  @override
  List<Object?> get props => [user, onFinished];
}
