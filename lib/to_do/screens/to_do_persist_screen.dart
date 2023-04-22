import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plannier/to_do/models/task.dart';

import '../bloc/to_do_bloc.dart';
import '../models/to_do.dart';

class ToDoPersistScreen extends StatefulWidget {
  const ToDoPersistScreen({Key? key}) : super(key: key);

  @override
  State<ToDoPersistScreen> createState() => _ToDoPersistScreenState();
}

class _ToDoPersistScreenState extends State<ToDoPersistScreen> {
  GlobalKey<FormState> key = GlobalKey<FormState>();
  TextEditingController title = TextEditingController();
  TextEditingController taskName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add To Do List'),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: key,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: title,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30,
                          fontFamily: 'Northwell',
                        ),
                        decoration: InputDecoration(
                          hintText: 'List Title',
                          hintStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 30,
                            fontFamily: 'Northwell',
                          ),
                          errorBorder: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: taskName,
                        decoration: const InputDecoration(
                          label: Text('Task name'),
                          hintText: 'Title',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              width: double.infinity,
              child: BlocBuilder<ToDoBloc, ToDoState>(
                builder: (context, state) {
                  if (state is ToDoLoaded) {
                    return state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              context.read<ToDoBloc>().add(
                                    ToDoAdd(
                                      toDo: ToDo(
                                        title: title.text,
                                        tasks: [
                                          Task(name: taskName.text, done: false)
                                        ],
                                      ),
                                      onFinished: () => Navigator.pop(context),
                                    ),
                                  );
                            },
                            child: const Text('Add To Do List'),
                          );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
