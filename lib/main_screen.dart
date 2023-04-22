import 'package:firebase_auth/firebase_auth.dart';
import 'package:plannier/events/screens/event_persist_screen.dart';
import 'package:plannier/events/screens/events_screen.dart';
import 'package:plannier/to_do/screens/to_do_persist_screen.dart';
import 'package:plannier/to_do/screens/to_do_screen.dart';
import 'package:plannier/utils/colors.dart';
import 'package:plannier/event_app_bar.dart';
import 'package:flutter/material.dart';

import 'home/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        appBar: EventAppBar(context: context),
        body: _currentIndex == 0
            ? HomeScreen(
                onSeeAllInvitations: () => setState(() => _currentIndex = 3))
            : _currentIndex == 1
                ? const EventsScreen()
                : _currentIndex == 2
                    ? const ToDoScreen()
                    : const SizedBox(),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: Colors.white,
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
                BottomTabSelector(
                  title: 'To Do',
                  onTap: () => setState(() => _currentIndex = 2),
                  icon: Icons.check_box_outlined,
                  isSelected: _currentIndex == 2,
                ),
                BottomTabSelector(
                  title: 'Invitations',
                  onTap: () => setState(() => _currentIndex = 3),
                  icon: Icons.email,
                  isSelected: _currentIndex == 3,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _currentIndex != 0
            ? ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(const CircleBorder()),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>_currentIndex==1?const EventPersistScreen():_currentIndex==2?ToDoPersistScreen():const Scaffold()));
                },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.add),
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}

class BottomTabSelector extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon;
  final bool isSelected;

  const BottomTabSelector({
    Key? key,
    required this.title,
    required this.onTap,
    required this.icon,
    this.isSelected = false,
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
                Icon(
                  icon,
                  color:
                      isSelected ? Theme.of(context).primaryColor : Colors.grey,
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
