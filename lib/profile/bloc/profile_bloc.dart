import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:plannier/events/models/user.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ref = FirebaseFirestore.instance.collection('/users');

  ProfileBloc()
      : super(
          ProfileLoaded(
            user: UserPlannier.fromFirebaseUser(
                FirebaseAuth.instance.currentUser),
            isLoading: false,
          ),
        ) {
    on<ProfileUpdate>(_onProfileUpdate);
  }

  Future<void> _onProfileUpdate(
      ProfileUpdate event, Emitter<ProfileState> emit) async {
    final s = state;
    if (s is ProfileLoaded) {
      emit(s.copyWith(isLoading: true));
      var user = FirebaseAuth.instance.currentUser;
      UserPlannier userPlannier =  UserPlannier.fromFirebaseUser(user);

      if (event.user.name != null &&
          event.user.name!.isNotEmpty &&
          event.user.name != user?.displayName) {
        user?.updateDisplayName(event.user.name);
        userPlannier = userPlannier.copyWith(name: event.user.name);
        await ref.doc(user?.uid).set({
          "email": user?.email,
          "name": "${event.user.name}",
          "photo": user?.photoURL,
        });
      }
      if (event.user.photo != null &&
          event.user.photo!.isNotEmpty &&
          event.user.photo != user?.photoURL) {
        user?.updatePhotoURL(event.user.photo);
        userPlannier = userPlannier.copyWith(photo: event.user.photo);
        await ref.doc(user?.uid).set({
          "email": user?.email,
          "name": user?.displayName,
          "photo": event.user.photo,
        });
      }
      emit(s.copyWith(
          user: userPlannier, isLoading: false));
      event.onFinished?.call();
    }
  }
}
