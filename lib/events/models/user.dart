import 'package:equatable/equatable.dart';

import 'event.dart';
import 'invitation.dart';

class User extends Equatable {
  final String? id;
  final String name;
  final List<Event> events;
  final List<Invitation> invitations;

  const User({
    this.id,
    required this.name,
    required this.events,
    required this.invitations,
  });

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        events = json['events'],
        invitations = json['invitations'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['events'] = events;
    data['invitations'] = invitations;
    return data;
  }

  @override
  List<Object?> get props => [id, name, events, invitations];
}
