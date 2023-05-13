import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plannier/events/models/event.dart';
import 'package:plannier/invitations/widgets/invitation_card.dart';

import '../events/bloc/event_bloc.dart';
import 'bloc/invitation_bloc.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({Key? key}) : super(key: key);

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  int indexPressed = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvitationBloc, InvitationState>(
      builder: (context, state) {
        if (state is InvitationLoaded) {
          return Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      setState(() => indexPressed = index);
                      context.read<InvitationBloc>().add(
                            InvitationFilter(
                              responseToFilter: indexPressed == 0
                                  ? null
                                  : Response.values[index - 1],
                            ),
                          );
                    },
                    child: Container(
                      margin:
                          index == 0 ? const EdgeInsets.only(left: 20) : null,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: indexPressed == index
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.white,
                        child: Container(
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: Text(
                              index == 0
                                  ? 'All'
                                  : capitalizeFirstLetter(
                                      Response.values[index - 1].name),
                              style: TextStyle(
                                color: indexPressed == index
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  itemCount: Response.values.length + 1,
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        margin:
                            const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: state.invitations.isEmpty
                            ? const Center(
                                child: Text('No Invitations'),
                              )
                            : ListView.separated(
                                itemBuilder: (context, index) {
                                  Event? event;
                                  int eventIndex = state.invitationEvents
                                      .indexWhere((element) =>
                                          element.id ==
                                          state.invitations[index].eventId);
                                  if (eventIndex != -1) {
                                    event = state.invitationEvents[eventIndex];
                                  }
                                  if (event != null) {
                                    return MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(
                                          value: context.read<InvitationBloc>(),
                                        ),
                                        BlocProvider.value(
                                          value: context.read<EventBloc>(),
                                        ),
                                      ],
                                      child: InvitationCard(
                                        event: event,
                                        invitation: state.invitations[index],
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                                itemCount: state.invitations.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 5),
                              ),
                      ),
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  String capitalizeFirstLetter(String text) {
    var firstLetter = text.substring(0, 1);
    firstLetter = firstLetter.toUpperCase();
    return firstLetter + text.substring(1, text.length);
  }
}
