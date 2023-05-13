import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plannier/events/screens/event_persist_screen.dart';
import 'package:plannier/events/screens/events_screen.dart';
import 'package:plannier/invitations/invitations_screen.dart';
import 'package:plannier/to_do/screens/to_do_persist_screen.dart';
import 'package:plannier/to_do/screens/to_do_screen.dart';
import 'package:plannier/utils/colors.dart';
import 'package:plannier/event_app_bar.dart';
import 'package:flutter/material.dart';

import 'events/bloc/event_bloc.dart';
import 'events/models/event.dart';
import 'home/screens/home_screen.dart';
import 'home/screens/upload_picture_screen.dart';
import 'invitations/bloc/invitation_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EventAppBar(context: context),
      floatingActionButton: _currentIndex != -1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UploadPictureScreen(),
                ),
              ),
              child: const Icon(Icons.video_camera_back_outlined),
            )
          : ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(const CircleBorder()),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _currentIndex == 1
                            ? MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(
                                    value: context.read<EventBloc>(),
                                  ),
                                  BlocProvider.value(
                                    value: context.read<InvitationBloc>(),
                                  ),
                                ],
                                child: const EventPersistScreen(),
                              )
                            : _currentIndex == 2
                                ? const ToDoPersistScreen()
                                : const Scaffold()));
              },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.add),
              ),
            ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //floating action button position to center
      body: _currentIndex == 0
          ? HomeScreen(
              onSeeAllInvitations: () => setState(() => _currentIndex = 3))
          : _currentIndex == 1
              ? MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                      value: context.read<EventBloc>(),
                    ),
                    BlocProvider.value(
                      value: context.read<InvitationBloc>(),
                    ),
                  ],
                  child: const EventsScreen(),
                )
              : _currentIndex == 2
                  ? const ToDoScreen()
                  : MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value: context.read<EventBloc>(),
                        ),
                        BlocProvider.value(
                          value: context.read<InvitationBloc>(),
                        ),
                      ],
                      child: const InvitationsScreen(),
                    ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BottomTabSelector(
                title: 'Home',
                onTap: () => setState(() => _currentIndex = 0),
                icon: Icons.house,
                isSelected: _currentIndex == 0,
              ),
              BottomTabSelector(
                title: 'Events',
                onTap: () => setState(() => _currentIndex = 1),
                icon: Icons.calendar_month,
                isSelected: _currentIndex == 1,
              ),
              const SizedBox(width: 50),
              BottomTabSelector(
                title: 'To Do',
                onTap: () => setState(() => _currentIndex = 2),
                icon: Icons.check_box_outlined,
                isSelected: _currentIndex == 2,
              ),
              BlocBuilder<InvitationBloc, InvitationState>(
                builder: (context, state) {
                  if (state is InvitationLoaded) {
                    return BottomTabSelector(
                      title: 'Invitations',
                      onTap: () => setState(() => _currentIndex = 3),
                      icon: Icons.email,
                      isSelected: _currentIndex == 3,
                      isNew: state.arePending,
                    );
                  } else {
                    return BottomTabSelector(
                      title: 'Invitations',
                      onTap: () => setState(() => _currentIndex = 3),
                      icon: Icons.email,
                      isSelected: _currentIndex == 3,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomTabSelector extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon;
  final bool isSelected;
  final bool? isNew;

  const BottomTabSelector({
    Key? key,
    required this.title,
    required this.onTap,
    required this.icon,
    this.isSelected = false,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Material(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    isNew ?? false
                        ? const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 10,
                          )
                        : const SizedBox(),
                  ],
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
