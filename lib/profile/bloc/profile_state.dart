part of 'profile_bloc.dart';

@immutable
abstract class ProfileState extends Equatable {}

class ProfileLoaded extends ProfileState {
  final UserPlannier user;
  final bool isLoading;

  ProfileLoaded({required this.user, required this.isLoading});

  ProfileLoaded copyWith({UserPlannier? user, bool? isLoading}) =>
      ProfileLoaded(
          user: user ?? this.user, isLoading: isLoading ?? this.isLoading);

  @override
  List<Object?> get props => [user, isLoading];
}
