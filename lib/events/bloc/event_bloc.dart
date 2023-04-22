import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

part 'event_event.dart';

part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  var ref = FirebaseFirestore.instance.collection(
      (FirebaseAuth.instance.currentUser != null
          ? '/users/${FirebaseAuth.instance.currentUser?.uid}/events'
          : '/events'));

  EventBloc() : super(EventLoaded(events: const [], isLoading: true)) {
    on<EventAdd>(_onEventAdd);
    on<EventFetch>(_onEventFetch);
    add(EventFetch());
  }

  Future<void> _onEventFetch(EventFetch event, Emitter<EventState> emit) async {
    try {
      final s = state;
      if (s is EventLoaded) {
        emit(s.copyWith(isLoading: true));
        QuerySnapshot querySnapshot = await ref.get();
        final allEvents = querySnapshot.docs.map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
        emit(s.copyWith(isLoading: false, events: allEvents));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onEventAdd(EventAdd event, Emitter<EventState> emit) async {
    try {
      final s = state;
      if (s is EventLoaded) {
        emit(s.copyWith(isLoading: true));
        var json = await ref.add(event.event.toJson());
        print(json);
        QuerySnapshot querySnapshot = await ref.get();
        final allEvents = querySnapshot.docs
            .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        emit(s.copyWith(isLoading: false, events: allEvents));
        event.onFinished?.call();
      }
    } catch (e) {
      print(e);
    }
  }
}
