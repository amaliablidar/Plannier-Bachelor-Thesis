import 'package:equatable/equatable.dart';
import 'package:plannier/events/models/event.dart';

class Invitation extends Equatable {
  final String? id;
  final String eventId;
  final String userId;
  final Response response;

  const Invitation({
    this.id,
    required this.eventId,
    required this.userId,
    required this.response,
  });

  Invitation.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        eventId = json['eventId'],
        userId = json['userId'],
        response = json['response'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventId'] = eventId;
    data['userId'] = userId;
    data['response'] = response;
    return data;
  }

  @override
  List<Object?> get props => [eventId, userId, response];
}
