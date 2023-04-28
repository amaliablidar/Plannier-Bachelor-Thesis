import 'package:equatable/equatable.dart';
import 'package:plannier/events/models/user.dart';

class Event extends Equatable {
  final String? id;
  final String name;
  final DateTime date;
  final String address;
  final String dressCode;
  final Map<String, Response> guests; //list of ids
  final String imageUrl;

  const Event({
    this.id,
    required this.name,
    required this.date,
    required this.address,
    required this.dressCode,
    required this.guests,
    required this.imageUrl,
  });

  Event.fromJson(Map<String, dynamic> json, String this.id)
      : name = json['name'],
        date = json['date'].toDate(),
        address = json['address'],
        dressCode = json['dressCode'],
        guests = Map<String, Response>.from(
          json['guests'].map(
            (String key, value) => MapEntry(
              key.toString(),
              Response.values.firstWhere((element) => element.name == value,
                  orElse: () => Response.pending),
            ),
          ),
        ),
        imageUrl = json['imageUrl'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['date'] = date;
    data['address'] = address;
    data['dressCode'] = dressCode;
    data['guests'] = guests.map(
      (String key, value) => MapEntry(
        key.toString(),
        value.name,
      ),
    );
    data['imageUrl'] = imageUrl;
    return data;
  }

  Event copyWith(
          {String? id,
          String? name,
          DateTime? date,
          String? address,
          String? dressCode,
          Map<String, Response>? guests,
          String? imageUrl}) =>
      Event(
          id: id ?? this.id,
          name: name ?? this.name,
          date: date ?? this.date,
          address: address ?? this.address,
          dressCode: dressCode ?? this.dressCode,
          guests: guests ?? this.guests,
          imageUrl: imageUrl ?? this.imageUrl);

  @override
  List<Object?> get props =>
      [id, name, date, address, dressCode, guests, imageUrl];
}

enum Response { accepted, pending, declined }
