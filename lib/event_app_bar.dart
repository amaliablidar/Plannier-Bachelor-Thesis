import 'dart:ui';

import 'package:plannier/utils/colors.dart';
import 'package:flutter/material.dart';

class EventAppBar extends AppBar {
  EventAppBar({Key? key, required BuildContext context})
      : super(
          key: key,
          toolbarHeight: 120,
          leadingWidth: 0,
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          automaticallyImplyLeading: false,
          title: const Padding(
            padding: EdgeInsets.only(left:10),
            child: Text(
              'Plannier',
              style: TextStyle(
                  fontFamily: 'Northwell', fontSize: 40, color: Colors.white),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 20),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2
                  ),
                  shape: BoxShape.circle),
            )
          ],
          centerTitle: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              color: PlannerieColors.primary,
            ),
          ),
        );
}
