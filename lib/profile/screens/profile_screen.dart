import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plannier/event_app_bar.dart';
import 'package:plannier/login/screens/login_screen.dart';
import 'package:plannier/utils/colors.dart';
import 'package:plannier/utils/platform_specific_dialog.dart';

import '../../login/bloc/auth_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 200,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            title: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2),
                        shape: BoxShape.circle),
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
                  const SizedBox(height: 10),
                  Text(
                    snapshot.data?.displayName ?? '',
                    style: const TextStyle(
                        fontFamily: 'Northwell',
                        fontSize: 40,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                color: PlannerieColors.primary,
              ),
            ),
          ),
          body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: const [
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const LogoutDialog(),
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PlatformSpecificDialog(
      title: const Text(
        'Logout',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Are you sure you want to logout?',
        style: TextStyle(fontSize: 14, color: Colors.black),
      ),
      actions: isLoading
          ? [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: CircularProgressIndicator(
                    color: PlannerieColors.primary,
                  ),
                ),
              )
            ]
          : [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('No')),
              TextButton(
                  onPressed: () async {
                    setState(() => isLoading = true);
                    context.read<AuthBloc>().add(
                          AuthLogout(
                            onFinished: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                          ),
                        );
                  },
                  child: const Text('Yes'))
            ],
    );
  }
}
