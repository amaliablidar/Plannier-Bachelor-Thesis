import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../utils/exceptions/network_exception.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final instance = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance.collection('/users');

  AuthBloc() : super(Unauthenticated()) {
    on<AuthLogin>(_onAuthLogin);
    on<AuthReload>(_onAuthReload);
    on<AuthLogout>(_onAuthLogout);
    on<AuthSignup>(_onAuthSignup);
    on<AuthResetPassword>(_onAuthResetPassword);
  }

  Future<void> _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    try {
      await instance.signInWithEmailAndPassword(
          email: event.email, password: event.password);

      emit(Authenticated());
      event.onFinished?.call();
    } catch (e) {
      print(e);
      _onError(e, emit);
    }
  }

  void _onAuthReload(AuthReload event, Emitter<AuthState> emit) async {
    emit(Unauthenticated());
  }

  void _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    try {
      await instance.signOut();
      emit(Unauthenticated());
      event.onFinished?.call();
    } catch (e) {
      print(e);
      _onError(e, emit);
    }
  }

  Future<void> _onAuthSignup(AuthSignup event, Emitter<AuthState> emit) async {
    try {
      UserCredential user = await instance.createUserWithEmailAndPassword(
          email: event.email, password: event.password);
      await user.user?.updatePhotoURL(event.imageUrl);
      await user.user
          ?.updateDisplayName('${event.firstName} ${event.lastName}');
      await ref.doc(user.user?.uid).set({
        'email': user.user?.email,
        "name": "${event.firstName} ${event.lastName}",
        'photo': event.imageUrl
      });
      emit(Unauthenticated());
      event.onFinished?.call();
    } catch (e) {
      print(e);
      _onError(e, emit);
    }
  }

  Future<void> _onAuthResetPassword(
      AuthResetPassword event, Emitter<AuthState> emit) async {
    try {
      await instance.sendPasswordResetEmail(email: event.email);
      emit(Unauthenticated());
      event.onFinished?.call();
    } catch (e) {
      print(e);
      _onError(e, emit);
    }
  }

  void _onError(dynamic e, Emitter<AuthState> emit) {
    if (e is FirebaseAuthException) {
      emit(AuthError(
          message: e.message ?? 'An error occurred, please try again'));
    } else {
      if (e is Error) log(e.toString());
      if (e is NetworkException && e.message != '') {
        emit(AuthError(message: e.message));
      } else {
        emit(AuthError(message: 'An error occurred, please try again.'));
      }
    }
  }
}
