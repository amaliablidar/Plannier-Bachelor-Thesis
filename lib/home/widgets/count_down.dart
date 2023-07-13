import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:plannier/events/screens/event_detail_screen.dart';
import 'package:plannier/utils/colors.dart';

import '../../events/bloc/event_bloc.dart';
import '../../invitations/bloc/invitation_bloc.dart';

class CountDown extends StatefulWidget {
  const CountDown({Key? key}) : super(key: key);

  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  late CountdownTimerController controller;

  void onEnd() {}

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state is EventLoaded) {
          controller = CountdownTimerController(
              endTime: state.nextEvent?.date.millisecondsSinceEpoch ??
                  DateTime.now().millisecondsSinceEpoch,
              onEnd: onEnd);
          return GestureDetector(
            onTap: state.nextEvent != null
                ? () => Navigator.push(
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
                          child: EventDetailScreen(event: state.nextEvent!),
                        ),
                      ),
                    )
                : null,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 210,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/event_placeholder.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 210,
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
                  child: state.nextEvent != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(state.nextEvent?.name ?? '',
                                  style: const TextStyle(
                                      fontFamily: 'Northwell',
                                      fontSize: 48,
                                      color: Colors.white)),
                              Text(
                                DateFormat('dd MMM yyyy').format(
                                    state.nextEvent?.date ?? DateTime.now()),
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 10),
                              CountdownTimer(
                                controller: controller,
                                endWidget: const Text(
                                  'The event is happening now',
                                  style: TextStyle(color: Colors.white),
                                ),
                                textStyle: GoogleFonts.rajdhani(
                                    color: Colors.white, fontSize: 30),
                                onEnd: onEnd,
                                endTime: state.nextEvent?.date
                                        .millisecondsSinceEpoch ??
                                    DateTime.now().millisecondsSinceEpoch,
                                widgetBuilder: (context, timeLeft) => Text(
                                  "${timeLeft?.days != null ? '${timeLeft?.days.toString()} Days,' : ''} ${timeLeft?.hours != null ? '${timeLeft?.hours.toString()} Hours,' : ''} ${timeLeft?.min != null ? '${timeLeft?.min.toString()} Min' : ''}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Center(
                          child: Text(
                            "No events in the upcoming future",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
