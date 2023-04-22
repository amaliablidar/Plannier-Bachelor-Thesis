import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String? id;
  final String name;
  final DateTime date;
  final String address;
  final String dressCode;
  final Map<String, dynamic> guests; //list of ids
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

  Event.fromJson(Map<String, dynamic> json, String id)
      : id = id,
        name = json['name'],
        date = json['date'].toDate(),
        address = json['address'],
        dressCode = json['dressCode'],
        guests = json['guests'],
        imageUrl = json['imageUrl'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['date'] = date;
    data['address'] = address;
    data['dressCode'] = dressCode;
    data['guests'] = guests;
    data['imageUrl'] = imageUrl;
    return data;
  }




  @override
  List<Object?> get props =>
      [id, name, date, address, dressCode, guests, imageUrl];
}

enum Response { accepted, pending, declined }
