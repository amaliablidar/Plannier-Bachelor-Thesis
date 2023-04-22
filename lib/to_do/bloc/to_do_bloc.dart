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
    add(ToDoFetch());
  }

  Future<void> _toDoFetch(ToDoFetch event, Emitter<ToDoState> emit) async {
    try {
      final s = state;
      if (s is ToDoLoaded) {
        emit(s.copyWith(isLoading: true));
        QuerySnapshot querySnapshot = await ref.get();
        final allToDo = querySnapshot.docs
            .map((doc) => ToDo.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        for (var i = 0; i < allToDo.length - 1; i++) {
          for (var j = i + 1; j < allToDo.length; j++) {
            if ((allToDo[i].lastEdit ?? DateTime.now())
                .isBefore(allToDo[j].lastEdit ?? DateTime.now())) {
              var aux = allToDo[i];
              allToDo[i] = allToDo[j];
              allToDo[j] = aux;
            }
          }
        }
        emit(
          s.copyWith(
            isLoading: false,
            toDo: allToDo,
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
}
