import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:plannier/events/models/event.dart';
import 'package:plannier/to_do/bloc/to_do_bloc.dart';


class ToDoScreen extends StatefulWidget {
  const ToDoScreen({Key? key}) : super(key: key);

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToDoBloc, ToDoState>(
        builder: (context, state) => state is ToDoLoaded
            ? state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: GridView.custom(
                      gridDelegate: SliverQuiltedGridDelegate(
                        crossAxisCount: 2,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        pattern: const [
                          QuiltedGridTile(2, 1),
                          QuiltedGridTile(1, 1),
                          QuiltedGridTile(1, 1),
                          QuiltedGridTile(1, 2),
                        ],
                      ),
                      childrenDelegate: SliverChildBuilderDelegate(
                        childCount: state.toDo.length,
                        (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.toDo[index].title ?? 'To Do',
                                  style: TextStyle(
                                    fontFamily: 'Northwell',
                                    fontSize: 20,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy HH:mm').format(
                                      state.toDo[index].lastEdit ??
                                          DateTime.now()),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                                Container(height: 5),
                                Expanded(
                                  child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, i) => Row(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                          ),
                                          child: state.toDo[index].tasks[i]
                                                      .done ??
                                                  false
                                              ? FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.check,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ),
                                        const Spacer(),
                                        Expanded(
                                          flex: 20,
                                          child: Text(state.toDo[index].tasks[i].name ??
                                              ''),
                                        ),
                                      ],
                                    ),
                                    itemCount: state.toDo[index].tasks.length,
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    )
                    // child: ListView.separated(
                    //   itemBuilder: (context, index) => Container(
                    //     height: 70,
                    //     padding: const EdgeInsets.all(10),
                    //     margin: state.toDo.length - 1 == index
                    //         ? const EdgeInsets.only(bottom: 20)
                    //         : EdgeInsets.zero,
                    //     decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.circular(8)),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         BlocBuilder<EventBloc, EventState>(
                    //           builder: (context, st) {
                    //             if (st is EventLoaded) {
                    //               return Text(
                    //                 getEventName(st.events,
                    //                     state.toDo[index].eventId ?? ''),
                    //                 style: const TextStyle(
                    //                     fontSize: 16,
                    //                     fontWeight: FontWeight.bold),
                    //               );
                    //             } else {
                    //               return const SizedBox();
                    //             }
                    //           },
                    //         ),
                    //         Text(
                    //           state.toDo[index].tasks.first.name ?? '',
                    //           style: const TextStyle(
                    //               fontSize: 16, fontWeight: FontWeight.bold),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //   itemCount: state.toDo.length,
                    //   separatorBuilder: (_, __) => const SizedBox(height: 5),
                    // ),
                    )
            : const SizedBox());
  }

  String getEventName(List<Event> events, String eventId) {
    int index = events.indexWhere((element) => element.id == eventId);
    if (index != -1) {
      return events[index].name;
    } else {
      return '';
    }
  }
}
