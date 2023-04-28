import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../invitations/bloc/invitation_bloc.dart';
import '../../utils/colors.dart';
import '../bloc/event_bloc.dart';
import '../widgets/event_card.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) => state is EventLoaded
          ? state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: state.events.isEmpty
                      ? const Center(
                          child: Text('Add Event to get Started'),
                        )
                      : ListView.separated(
                          itemBuilder: (context, index) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: context.read<EventBloc>(),
                              ),
                              BlocProvider.value(
                                value: context.read<InvitationBloc>(),
                              ),
                            ],
                            child: EventCard(event: state.events[index]),
                          ),
                          itemCount: state.events.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 5),
                        ),
                )
          : const SizedBox(),
    );
  }
}
