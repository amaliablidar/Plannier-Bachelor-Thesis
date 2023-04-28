import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plannier/events/models/event.dart';
import 'package:plannier/events/screens/event_detail_screen.dart';
import 'package:plannier/events/screens/event_persist_screen.dart';

import '../../invitations/bloc/invitation_bloc.dart';
import '../../utils/colors.dart';
import '../bloc/event_bloc.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
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
            child: EventDetailScreen(event: event),
          ),
        ),
      ),
      child: Stack(
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
                  const SizedBox(height: 10),
                  Text(DateFormat('dd MMMM yyyy HH:mm').format(event.date),
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(height: 5),
                  Text(event.address,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
