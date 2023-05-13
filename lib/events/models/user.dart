import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'event.dart';
import 'invitation.dart';

class UserPlannier extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final String? photo;

  const UserPlannier({
    this.id,
    this.name,
    this.email,
    this.photo,
  });

  UserPlannier.fromJson(Map<String, dynamic> json, String this.id)
      : name = json['name'],
        photo = json['photo'],
        email = json['email'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['photo'] = photo;
    data['email'] = email;
    return data;
  }

  UserPlannier copyWith({
    String? name,
    String? email,
    String? photo,
  }) =>
      UserPlannier(
        id: id,
        name: name ?? this.name,

        photo: photo ?? this.photo,
        email: email ?? this.email,
      );

  UserPlannier.fromFirebaseUser(User? user)
      : id = user?.uid,
        name = user?.displayName,
        email = user?.email,
        photo = user?.photoURL;

  @override
  List<Object?> get props => [
        id,
        name,
        photo,
        email,
      ];
}
