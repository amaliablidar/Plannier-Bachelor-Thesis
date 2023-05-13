import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plannier/events/models/event.dart';
import 'package:plannier/invitations/bloc/invitation_bloc.dart';
import 'package:plannier/utils/platform_specific_dialog.dart';

import '../../events/bloc/event_bloc.dart';
import '../../events/models/invitation.dart';
import '../../utils/colors.dart';

class InvitationCard extends StatelessWidget {
  const InvitationCard(
      {Key? key, required this.invitation, required this.event})
      : super(key: key);
  final Invitation invitation;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${invitation.userName} invited you to',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    event.name,
                    style: const TextStyle(
                      fontFamily: 'Northwell',
                      fontSize: 48,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
                Text(DateFormat('dd MMMM yyyy HH:mm').format(event.date),
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
        invitation.response == Response.pending
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: context.read<InvitationBloc>(),
                              ),
                              BlocProvider.value(
                                value: context.read<EventBloc>(),
                              ),
                            ],
                            child: PlatformSpecificDialog(
                              title: Text(
                                  'Are you sure you want to decline invitation to ${event.name}?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                BlocBuilder<InvitationBloc, InvitationState>(
                                  builder: (context, state) {
                                    if (state is InvitationLoaded) {
                                      return state.isLoading
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15.0),
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : TextButton(
                                              onPressed: () {
                                                context
                                                    .read<InvitationBloc>()
                                                    .add(
                                                      InvitationResponse(
                                                        invitation:
                                                            invitation.copyWith(
                                                                response: Response
                                                                    .declined),
                                                        onFinished: () =>
                                                            context
                                                                .read<
                                                                    EventBloc>()
                                                                .add(
                                                                  EventFetch(
                                                                    onFinished: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                  ),
                                                                ),
                                                      ),
                                                    );
                                              },
                                              child: const Text('Yes'));
                                    } else {
                                      return const SizedBox();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: const BoxDecoration(
                          color: PlannerieColors.secondary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'DECLINE',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: context.read<InvitationBloc>(),
                              ),
                              BlocProvider.value(
                                value: context.read<EventBloc>(),
                              ),
                            ],
                            child: PlatformSpecificDialog(
                              title: Text(
                                  'Are you sure you want to accept invitation to ${event.name}?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                BlocBuilder<InvitationBloc, InvitationState>(
                                  builder: (context, state) {
                                    if (state is InvitationLoaded) {
                                      return state.isLoading
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15.0),
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : TextButton(
                                              onPressed: () {
                                                context
                                                    .read<InvitationBloc>()
                                                    .add(
                                                      InvitationResponse(
                                                        invitation:
                                                            invitation.copyWith(
                                                                response: Response
                                                                    .accepted),
                                                        onFinished: () =>
                                                            context
                                                                .read<
                                                                    EventBloc>()
                                                                .add(
                                                                  EventFetch(
                                                                    onFinished: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                  ),
                                                                ),
                                                      ),
                                                    );
                                              },
                                              child: const Text('Yes'));
                                    } else {
                                      return const SizedBox();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: const BoxDecoration(
                          color: PlannerieColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'ACCEPT',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                height: 50,
                decoration: BoxDecoration(
                  color: invitation.response == Response.accepted
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    invitation.response.name.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
      ],
    );
  }
}
