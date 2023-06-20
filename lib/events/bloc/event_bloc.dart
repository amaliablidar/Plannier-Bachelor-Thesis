import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plannier/events/models/user.dart';
import '../models/event.dart';
import '../models/invitation.dart';

part 'event_event.dart';

part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  var ref = FirebaseFirestore.instance.collection(
      (FirebaseAuth.instance.currentUser != null
          ? '/users/${FirebaseAuth.instance.currentUser?.uid}/events'
          : '/events'));
  var refGuests = FirebaseFirestore.instance.collection('/users');

  EventBloc()
      : super(EventLoaded(events: const [], isLoading: true, guests: [])) {
    on<EventAdd>(_onEventAdd);
    on<EventUpdate>(_onEventUpdate);
    on<EventFetch>(_onEventFetch);
    on<EventDelete>(_onEventDelete);
    add(EventFetch());
  }

  Future<void> _onEventFetch(EventFetch event, Emitter<EventState> emit) async {
    try {
      final s = state;
      if (s is EventLoaded) {
        emit(s.copyWith(isLoading: true));
        QuerySnapshot querySnapshot = await ref.get();
        final allEvents = querySnapshot.docs.map((doc) {
          return Event.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        QuerySnapshot querySnapshotGuests = await refGuests.get();
        final allGuests = querySnapshotGuests.docs
            .map((e) =>
                UserPlannier.fromJson(e.data() as Map<String, dynamic>, e.id))
            .toList();
        var closestDate = allEvents.first.date;
        Event closestEvent = allEvents.first;
        for (int i = 1; i < allEvents.length; i++) {
          if (allEvents[i].date.isBefore(closestDate) &&
              allEvents[i].date.isAfter(DateTime.now())) {
            closestDate = allEvents[i].date;
            closestEvent = allEvents[i];
          }
        }
        emit(s.copyWith(
            isLoading: false,
            events: allEvents,
            guests: allGuests,
            nextEvent: closestEvent));
      }
      event.onFinished?.call();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onEventAdd(EventAdd event, Emitter<EventState> emit) async {
    try {
      final s = state;
      if (s is EventLoaded) {
        emit(s.copyWith(isLoading: true));

        var e = await ref.add(event.event.toJson());

        QuerySnapshot querySnapshot = await ref.get();

        for (var guestId in event.event.guests.keys) {
          var ref = FirebaseFirestore.instance
              .collection('/users/$guestId/invitations');

          ref.add(Invitation(
            eventId: e.id,
            userName: FirebaseAuth.instance.currentUser?.displayName ?? '',
            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
            response: event.event.guests[guestId] ?? Response.pending,
          ).toJson());
        }
        final allEvents = querySnapshot.docs
            .map((doc) =>
                Event.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        emit(s.copyWith(isLoading: false, events: allEvents));
        add(EventFetch(onFinished: event.onFinished));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onEventUpdate(
      EventUpdate event, Emitter<EventState> emit) async {
    try {
      final s = state;
      if (s is EventLoaded) {
        emit(s.copyWith(isLoading: true));
        var eventJson = await ref.doc(event.event.id).get();
        Event? eventData;
        if (eventJson.data() != null) {
          eventData = Event.fromJson(eventJson.data()!, eventJson.id);
        }
        Event eventToUpdate = event.event;
        var guestsToUpdate = event.event.guests;

        for (var guestId in guestsToUpdate.keys) {
          if (eventData != null) {
            var containsGuest = eventData.guests.keys.contains(guestId);
            if (!containsGuest) {
              var ref = FirebaseFirestore.instance
                  .collection('/users/$guestId/invitations');
              ref.add(Invitation(
                eventId: event.event.id ?? '',
                userName: FirebaseAuth.instance.currentUser?.displayName ?? '',
                userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                response: event.event.guests[guestId] ?? Response.pending,
              ).toJson());
            } else {
              guestsToUpdate[guestId] =
                  eventData.guests[guestId] ?? Response.pending;
            }
          }
        }
        eventToUpdate = eventToUpdate.copyWith(guests: guestsToUpdate);

        await ref.doc(event.event.id).update(eventToUpdate.toJson());

        if (eventData != null) {
          for (var eventGuestId in eventData.guests.keys) {
            var containsGuest = event.event.guests.keys.contains(eventGuestId);
            if (!containsGuest) {
              try {
                var ref = FirebaseFirestore.instance
                    .collection('/users/$eventGuestId/invitations');
                var invitationsJson = await ref.get();
                var invitationList = invitationsJson.docs
                    .map((e) => Invitation.fromJson(e.data(), e.id))
                    .toList();
                var invitationToDelete = invitationList
                    .firstWhere((element) => element.eventId == event.event.id);
                await ref.doc(invitationToDelete.id).delete();
              } catch (e) {
                print(e);
              }
            }
          }
        }

        QuerySnapshot querySnapshot = await ref.get();
        final allEvents = querySnapshot.docs
            .map((doc) =>
                Event.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        emit(s.copyWith(isLoading: false, events: allEvents));
        add(EventFetch(onFinished: event.onFinished));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onEventDelete(
      EventDelete event, Emitter<EventState> emit) async {
    try {
      final s = state;
      if (s is EventLoaded) {
        emit(s.copyWith(isLoading: true));
        await ref.doc(event.event?.id).delete();
        QuerySnapshot querySnapshot = await ref.get();
        final allEvents = querySnapshot.docs
            .map((doc) =>
                Event.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        if(event.event!=null) {
          for (var eventGuestId in event.event!.guests.keys) {
            var containsGuest = event.event!.guests.keys.contains(eventGuestId);
            if (!containsGuest) {
              try {
                var ref = FirebaseFirestore.instance
                    .collection('/users/$eventGuestId/invitations');
                var invitationsJson = await ref.get();
                var invitationList = invitationsJson.docs
                    .map((e) => Invitation.fromJson(e.data(), e.id))
                    .toList();
                var invitationToDelete = invitationList
                    .firstWhere((element) => element.eventId == event.event!.id);
                await ref.doc(invitationToDelete.id).delete();
              } catch (e) {
                print(e);
              }
            }
          }
        }
        emit(s.copyWith(isLoading: false, events: allEvents));
        event.onFinished?.call();
      }
    } catch (e) {
      print(e);
    }
  }
}
