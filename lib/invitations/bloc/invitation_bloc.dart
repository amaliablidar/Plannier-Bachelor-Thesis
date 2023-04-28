import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../events/models/event.dart';
import '../../events/models/invitation.dart';

part 'invitation_event.dart';

part 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  var ref = FirebaseFirestore.instance.collection(
      '/users/${FirebaseAuth.instance.currentUser?.uid}/invitations');

  InvitationBloc()
      : super(InvitationLoaded(
          invitations: const [],
          isLoading: true,
          invitationEvents: const [],
          arePending: false,
        )) {
    on<InvitationFetch>(_onInvitationFetch);
    on<InvitationResponse>(_onInvitationResponse);
    on<InvitationFilter>(_onInvitationFilter);
    add(InvitationFetch());
  }

  Future<void> _onInvitationFetch(
      InvitationFetch event, Emitter<InvitationState> emit) async {
    try {
      final s = state;
      if (s is InvitationLoaded) {
        emit(s.copyWith(isLoading: true));
        var querySnapshot = await ref.get();
        final allInvitations = querySnapshot.docs.map((doc) {
          return Invitation.fromJson(doc.data(), doc.id);
        }).toList();
        for (int i = 0; i < allInvitations.length - 1; i++) {
          for (int j = i + 1; j < allInvitations.length; j++) {
            if (allInvitations[j].response == Response.pending &&
                allInvitations[i].response != Response.pending) {
              var aux = allInvitations[i];
              allInvitations[i] = allInvitations[j];
              allInvitations[j] = aux;
            }
          }
        }

        List<Event> invitationEvents = [];
        for (var invitation in allInvitations) {
          var refUserEvents = FirebaseFirestore.instance
              .collection('/users/${invitation.userId}/events');
          var snapshot = await refUserEvents.doc(invitation.eventId).get();
          if (snapshot.data() != null) {
            var event = Event.fromJson(snapshot.data()!, snapshot.id);
            invitationEvents.add(event);
          }
        }
        var index = allInvitations
            .indexWhere((element) => element.response == Response.pending);

        emit(s.copyWith(
            invitations: allInvitations,
            isLoading: false,
            arePending: index != -1,
            invitationEvents: invitationEvents));
      }
      event.onFinished?.call();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onInvitationResponse(
      InvitationResponse event, Emitter<InvitationState> emit) async {
    try {
      final s = state;
      if (s is InvitationLoaded) {
        emit(s.copyWith(isLoading: true));
        var refUser = FirebaseFirestore.instance
            .collection('/users/${event.invitation.userId}/events');
        var eventJson = await refUser.doc(event.invitation.eventId).get();
        if (eventJson.data() != null) {
          var eventData = Event.fromJson(eventJson.data()!, eventJson.id);
          var guests = eventData.guests;
          if (FirebaseAuth.instance.currentUser != null) {
            guests[FirebaseAuth.instance.currentUser!.uid] =
                event.invitation.response;
          }
          eventData = eventData.copyWith(guests: guests);
          refUser.doc(event.invitation.eventId).update(eventData.toJson());
        }
        ref.doc(event.invitation.id).update(event.invitation.toJson());
        add(InvitationFetch(onFinished: event.onFinished));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onInvitationFilter(
      InvitationFilter event, Emitter<InvitationState> emit) async {
    try {
      final s = state;
      if (s is InvitationLoaded) {
        emit(s.copyWith(isLoading: true));
        var querySnapshot = await ref.get();
        var allInvitations = querySnapshot.docs.map((doc) {
          return Invitation.fromJson(doc.data(), doc.id);
        }).toList();
        List<Invitation> filteredInvitations = [];
        if (event.responseToFilter != null) {
          filteredInvitations = allInvitations
              .where((element) => element.response == event.responseToFilter)
              .toList();
        } else {
          filteredInvitations = allInvitations;
        }
        List<Event> invitationEvents = [];
        for (var invitation in filteredInvitations) {
          var refUserEvents = FirebaseFirestore.instance
              .collection('/users/${invitation.userId}/events');
          var snapshot = await refUserEvents.doc(invitation.eventId).get();
          if (snapshot.data() != null) {
            var event = Event.fromJson(snapshot.data()!, snapshot.id);
            invitationEvents.add(event);
          }
        }
        var index = allInvitations
            .indexWhere((element) => element.response == Response.pending);

        emit(s.copyWith(
            invitations: filteredInvitations,
            isLoading: false,
            arePending: index != -1,
            invitationEvents: invitationEvents));
      }
    } catch (e) {
      print(e);
    }
  }
}
