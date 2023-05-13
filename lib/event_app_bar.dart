import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plannier/invitations/bloc/invitation_bloc.dart';
import 'package:plannier/profile/screens/profile_screen.dart';
import 'package:plannier/utils/colors.dart';
import 'package:flutter/material.dart';

import 'events/bloc/event_bloc.dart';

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
              bottomRight: Radius.circular(10),
            ),
          ),
          automaticallyImplyLeading: false,
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Plannier',
              style: TextStyle(
                fontFamily: 'Northwell',
                fontSize: 40,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                        value: context.read<InvitationBloc>(),
                      ),
                      BlocProvider.value(
                        value: context.read<EventBloc>(),
                      ),
                    ],
                    child: const ProfileScreen(),
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: FirebaseAuth.instance.currentUser != null &&
                        FirebaseAuth.instance.currentUser?.photoURL != null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          FirebaseAuth.instance.currentUser!.photoURL!,
                        ),
                      )
                    : const SizedBox(),
              ),
            )
          ],
          centerTitle: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              color: PlannerieColors.primary,
            ),
          ),
        );
}
