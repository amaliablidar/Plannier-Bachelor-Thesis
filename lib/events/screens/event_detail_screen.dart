import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plannier/events/models/event.dart';
import 'package:plannier/events/screens/event_persist_screen.dart';

import '../../invitations/bloc/invitation_bloc.dart';
import '../../utils/colors.dart';
import '../bloc/event_bloc.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({Key? key, required this.event}) : super(key: key);
  final Event event;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          BlocBuilder<EventBloc, EventState>(
            builder: (context, state) {
              if (state is EventLoaded) {
                var index = state.events
                    .indexWhere((element) => element.id == widget.event.id);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                              value: context.read<EventBloc>(),
                            ),
                            BlocProvider.value(
                              value: context.read<InvitationBloc>(),
                            ),
                          ],
                          child: EventPersistScreen(event: state.events[index]),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.edit),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoaded) {
            int index = state.events
                .indexWhere((element) => element.id == widget.event.id);
            if (index != -1) {
              event = state.events[index];
            }
            return Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 230,
                                  width: double.infinity,
                                  child: Image.asset(
                                    'assets/event_placeholder.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                height: 230,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0),
                                      PlannerieColors.primary.withOpacity(0),
                                      PlannerieColors.primary.withOpacity(0.2),
                                      PlannerieColors.primary.withOpacity(1),
                                    ],
                                    stops: const [
                                      0,
                                      0.1,
                                      0.1,
                                      0.4,
                                      1,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    event?.name ?? widget.event.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 50,
                                      fontFamily: 'Northwell',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Date',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                    Expanded(
                                      child: Text(
                                        DateFormat('dd MMMM yyyy').format(
                                            event?.date ?? widget.event.date),
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Location',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                    Expanded(
                                      child: Text(
                                        event?.address ?? widget.event.address,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'Guest list',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                BlocBuilder<EventBloc, EventState>(
                                    builder: (context, state) {
                                  if (state is EventLoaded) {
                                    return Column(
                                      children: List.generate(
                                        event?.guests.keys.length ??
                                            widget.event.guests.keys.length,
                                        (index) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${state.guests.firstWhere((element) => element.id == event?.guests.keys.elementAt(index)).name}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                capitalizeFirstLetter(event
                                                        ?.guests.values
                                                        .elementAt(index)
                                                        .name ??
                                                    ''),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: event?.guests.values
                                                              .elementAt(
                                                                  index) ==
                                                          Response.accepted
                                                      ? Colors.green
                                                      : event?.guests.values
                                                                  .elementAt(
                                                                      index) ==
                                                              Response.declined
                                                          ? Colors.red
                                                          : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                })
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  String capitalizeFirstLetter(String text) {
    var firstLetter = text.substring(0, 1);
    firstLetter = firstLetter.toUpperCase();
    return firstLetter + text.substring(1, text.length);
  }
}
