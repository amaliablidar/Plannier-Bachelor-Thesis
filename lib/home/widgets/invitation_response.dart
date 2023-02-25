import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class InvitationResponse extends StatelessWidget {
  const InvitationResponse({Key? key}) : super(key: key);

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
              children: const [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    'Amanda\'s bridal shower',
                    style: TextStyle(
                      fontFamily: 'Northwell',
                      fontSize: 48,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
                Text('17 Noiembrie 2023',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
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
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
              ),
            ),
            Expanded(
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
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ],
        )
      ],
    );
  }
}
