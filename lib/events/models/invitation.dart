import 'package:equatable/equatable.dart';
import 'package:plannier/events/models/event.dart';

class Invitation extends Equatable {
  final String? id;
  final String eventId;
  final String userId;
  final String userName;
  final Response response;

  const Invitation({
    this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.response,
  });

  Invitation.fromJson(Map<String, dynamic> json, String this.id)
      : eventId = json['eventId'],
        userId = json['userId'],
        userName = json['userName'],
        response = Response.values
            .firstWhere((element) => element.name == json['response']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventId'] = eventId;
    data['userName'] = userName;
    data['userId'] = userId;
    data['response'] = response.name;
    return data;
  }

  Invitation copyWith(
          {String? id,
          String? eventId,
          String? userId,
          Response? response,
          String? userName}) =>
      Invitation(
          id: id ?? this.id,
          eventId: eventId ?? this.eventId,
          userId: userId ?? this.userId,
          userName: userName ?? this.userName,
          response: response ?? this.response);

  @override
  String toString() {
    return 'Invitation{id: $id, eventId: $eventId, userId: $userId, userName: $userName, response: $response}';
  }

  @override
  List<Object?> get props => [id, eventId, userId, response, userName];
}
