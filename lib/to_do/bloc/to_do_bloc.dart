import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../models/to_do.dart';

part 'to_do_event.dart';

part 'to_do_state.dart';

class ToDoBloc extends Bloc<ToDoEvent, ToDoState> {
  var ref = FirebaseFirestore.instance.collection(
      (FirebaseAuth.instance.currentUser != null
          ? '/users/${FirebaseAuth.instance.currentUser?.uid}/todo'
          : '/todo'));

  ToDoBloc() : super(ToDoLoaded(toDo: const [], isLoading: true)) {
    on<ToDoFetch>(_toDoFetch);
    on<ToDoAdd>(_toDoAdd);
    on<ToDoUpdate>(_toDoUpdate);
    on<ToDoDelete>(_toDoDelete);
    add(ToDoFetch());
  }

  Future<void> _toDoFetch(ToDoFetch event, Emitter<ToDoState> emit) async {
    try {
      final s = state;
      if (s is ToDoLoaded) {
        emit(s.copyWith(isLoading: true));
        QuerySnapshot querySnapshot = await ref.get();
        final allToDo = querySnapshot.docs
            .map((doc) =>
                ToDo.fromJson(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
        List<ToDo> toDo = List.from(allToDo);
        for (var i = 0; i < toDo.length - 1; i++) {
          for (var j = i + 1; j < toDo.length; j++) {
            if ((toDo[i].lastEdit ?? DateTime.now())
                .isBefore(toDo[j].lastEdit ?? DateTime.now())) {
              var aux = toDo[i];
              toDo[i] = toDo[j];
              toDo[j] = aux;
            }
          }
        }
        emit(
          s.copyWith(
            isLoading: false,
            toDo: toDo,
          ),
        );
        event.onFinished?.call();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _toDoAdd(ToDoAdd event, Emitter<ToDoState> emit) async {
    try {
      final s = state;
      if (s is ToDoLoaded) {
        emit(s.copyWith(isLoading: true));
        await ref.add(event.toDo.toJson());
        add(ToDoFetch(onFinished: event.onFinished));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _toDoUpdate(ToDoUpdate event, Emitter<ToDoState> emit) async {
    try {
      final s = state;
      if (s is ToDoLoaded) {
        emit(s.copyWith(isLoading: true));
        await ref.doc(event.toDo.id).update(event.toDo.toJson());
        add(ToDoFetch(onFinished: event.onFinished));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _toDoDelete(ToDoDelete event, Emitter<ToDoState> emit) async {
    try {
      final s = state;
      if (s is ToDoLoaded) {
        emit(s.copyWith(isLoading: true));
        await ref.doc(event.toDoId).delete();
        add(ToDoFetch(onFinished: event.onFinished));
      }
    } catch (e) {
      print(e);
    }
  }
}
