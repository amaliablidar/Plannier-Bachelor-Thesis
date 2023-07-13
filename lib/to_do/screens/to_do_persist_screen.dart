import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plannier/to_do/models/task.dart';
import 'package:plannier/utils/platform_specific_dialog.dart';

import '../bloc/to_do_bloc.dart';
import '../models/to_do.dart';

class ToDoPersistScreen extends StatefulWidget {
  const ToDoPersistScreen({Key? key, this.toDo}) : super(key: key);
  final ToDo? toDo;

  @override
  State<ToDoPersistScreen> createState() => _ToDoPersistScreenState();
}

class _ToDoPersistScreenState extends State<ToDoPersistScreen> {
  GlobalKey<FormState> key = GlobalKey<FormState>();
  TextEditingController title = TextEditingController();
  List<TextEditingController> tasksControllers = [];
  List<bool> tasksDone = [];
  bool isValid = false;

  @override
  void initState() {
    if (widget.toDo != null) {
      title.text = widget.toDo!.title ?? '';
      for (int i = 0; i < widget.toDo!.tasks.length; i++) {
        tasksControllers
            .add(TextEditingController(text: widget.toDo!.tasks[i].name));
        tasksDone.add(widget.toDo!.tasks[i].done ?? false);
      }
    } else {
      tasksControllers.add(TextEditingController());
      tasksDone.add(false);
    }
    isValid = formValid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: widget.toDo != null
            ? Text(
                widget.toDo!.title ?? 'Edit To Do List',
                overflow: TextOverflow.ellipsis,
              )
            : const Text('Add To Do List'),
        actions: [
          if (widget.toDo != null)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => PlatformSpecificDialog(
                    title: const Text(
                        'Are you sure you want to delete this list?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      BlocBuilder<ToDoBloc, ToDoState>(
                        builder: (context, state) {
                          if (state is ToDoLoaded) {
                            return state.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.only(
                                        right: 20, left: 10, top: 5),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : TextButton(
                                    onPressed: () {
                                      context.read<ToDoBloc>().add(
                                            ToDoDelete(
                                              toDoId: widget.toDo!.id ?? '',
                                              onFinished: () {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          );
                                    },
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  );
                          } else {
                            return const SizedBox();
                          }
                        },
                      )
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.transparent,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
        ],
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
                        onChanged: (value) =>
                            setState(() => isValid = formValid()),
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
                      Column(
                        children: List.generate(
                          tasksControllers.length,
                          (index) => Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: tasksDone[index],
                                onChanged: (value) => setState(() {
                                  tasksDone[index] = value ?? false;
                                  isValid = formValid();
                                }),
                              ),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  controller: tasksControllers[index],
                                  decoration: const InputDecoration(
                                    hintText: 'Task Name',
                                  ),
                                  onChanged: (value) =>
                                      setState(() => isValid = formValid()),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() {
                                  tasksControllers.removeAt(index);
                                  tasksDone.removeAt(index);
                                }),
                                child: const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => setState(() {
                          tasksControllers.add(TextEditingController());
                          tasksDone.add(false);
                        }),
                        child: const Text(
                          ' + Add Task',
                          style: TextStyle(fontSize: 14),
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
                            onPressed: formValid()
                                ? widget.toDo != null
                                    ? () {
                                        context.read<ToDoBloc>().add(
                                              ToDoUpdate(
                                                toDo: widget.toDo!.copyWith(
                                                  title: title.text,
                                                  tasks: List.generate(
                                                    tasksControllers.length,
                                                    (index) => Task(
                                                      name: tasksControllers[
                                                              index]
                                                          .text,
                                                      done: tasksDone[index],
                                                    ),
                                                  ),
                                                ),
                                                onFinished: () =>
                                                    Navigator.pop(context),
                                              ),
                                            );
                                      }
                                    : () {
                                        context.read<ToDoBloc>().add(
                                              ToDoAdd(
                                                toDo: ToDo(
                                                  title: title.text,
                                                  tasks: List.generate(
                                                    tasksControllers.length,
                                                    (index) => Task(
                                                      name: tasksControllers[
                                                              index]
                                                          .text,
                                                      done: tasksDone[index],
                                                    ),
                                                  ),
                                                ),
                                                onFinished: () =>
                                                    Navigator.pop(context),
                                              ),
                                            );
                                      }
                                : null,
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    formValid()
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey)),
                            child: widget.toDo != null
                                ? const Text(
                                    'Update List',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : const Text(
                                    'Add List',
                                    style: TextStyle(color: Colors.white),
                                  ),
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

  bool formValid() {
    try {
      var titleIncomplete = title.text.isEmpty;
      if (titleIncomplete) {
        return false;
      }
      tasksControllers.firstWhere((e) => e.text.isEmpty);
      return false;
    } catch (e) {
      return true;
    }
  }
}
