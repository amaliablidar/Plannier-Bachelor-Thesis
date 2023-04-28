import 'package:equatable/equatable.dart';

import 'event.dart';
import 'invitation.dart';

class UserPlannier extends Equatable {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? photo;

  const UserPlannier({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.photo,
  });

  UserPlannier.fromJson(Map<String, dynamic> json, String this.id)
      : firstName = json['firstName'],
        lastName = json['lastName'],
        photo = json['photo'],
        email = json['email'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['photo'] = photo;
    data['email'] = email;
    return data;
  }

  UserPlannier copyWith(
          {String? firstName,
          String? lastName,
          String? email,
          String? photo,}) =>
      UserPlannier(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        photo: photo ?? this.photo,
        email: email ?? this.email,
      );

  @override
  List<Object?> get props =>
      [id, firstName, lastName, photo, email, ];
}
