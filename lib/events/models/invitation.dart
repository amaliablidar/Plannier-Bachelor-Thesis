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

  Invitation.fromJson(Map<String, dynamic> json, String this.id)
      : eventId = json['eventId'],
        userId = json['userId'],
        response = Response.values
            .firstWhere((element) => element.name == json['response']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventId'] = eventId;
    data['userId'] = userId;
    data['response'] = response.name;
    return data;
  }

  Invitation copyWith(
          {String? id, String? eventId, String? userId, Response? response}) =>
      Invitation(
          id: id ?? this.id,
          eventId: eventId ?? this.eventId,
          userId: userId ?? this.userId,
          response: response ?? this.response);

  @override
  String toString() {
    return 'Invitation{id: $id, eventId: $eventId, userId: $userId, response: $response}';
  }

  @override
  List<Object?> get props => [id, eventId, userId, response];
}
