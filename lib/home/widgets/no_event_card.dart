
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class NoEventCard extends StatelessWidget {
  const NoEventCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: 102,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: PlannerieColors.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text.rich(
                  TextSpan(
                    text: 'Hello, ',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    children: [
                      TextSpan(
                        text: 'Amalia',
                        style: TextStyle(
                            fontFamily: 'Desyrel',
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      TextSpan(
                        text: ' !',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Add an event to start planning.',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
            const Icon(
              Icons.add,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
