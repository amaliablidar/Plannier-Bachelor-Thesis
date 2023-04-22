import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/event_bloc.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
        builder: (context, state) => state is EventLoaded
            ? state.isLoading? const Center(child: CircularProgressIndicator()):Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: ListView.separated(
                  itemBuilder: (context, index) => Container(
                    height: 70,
                    padding: const EdgeInsets.all(10),
                    margin: state.events.length-1==index?const EdgeInsets.only(bottom: 20):EdgeInsets.zero,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.events[index].name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        Text(state.events[index].address, style: const TextStyle(fontSize: 14),),
                      ],
                    ),
                  ),
                  itemCount: state.events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 5),
                ),
              )
            : const SizedBox());
  }
}
