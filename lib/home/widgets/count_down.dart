import 'package:plannier/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';

class CountDown extends StatefulWidget {
  const CountDown({Key? key}) : super(key: key);

  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  late CountdownTimerController controller;
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 10000000;

  @override
  void initState() {
    super.initState();
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
  }

  void onEnd() {}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(height: 210,width: double.infinity,child: Image.asset('assets/event_placeholder.jpg', fit: BoxFit.cover,))),
        Container(
          height: 210,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient:  LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0),
                PlannerieColors.primary.withOpacity(0),
                PlannerieColors.primary.withOpacity(0.2),
                PlannerieColors.primary.withOpacity(1),
              ],
              stops: const [
                0,0.1,
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
                const Text('My birthday party',
                    style: TextStyle(
                        fontFamily: 'Northwell',
                        fontSize: 48,
                        color: Colors.white)),
                const Text('17 Noiembrie 2023',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 10),
                CountdownTimer(
                  controller: controller,
                  endWidget: const Text(
                    'The event is happening now',
                    style: TextStyle(color: Colors.white),
                  ),
                  textStyle:
                      GoogleFonts.rajdhani(color: Colors.white, fontSize: 30),
                  onEnd: onEnd,
                  endTime: endTime,
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
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
