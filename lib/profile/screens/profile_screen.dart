import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plannier/events/models/event.dart';
import 'package:plannier/events/models/user.dart';
import 'package:plannier/login/screens/login_screen.dart';
import 'package:plannier/profile/bloc/profile_bloc.dart';
import 'package:plannier/to_do/bloc/to_do_bloc.dart';
import 'package:plannier/utils/colors.dart';
import 'package:plannier/utils/platform_specific_dialog.dart';

import '../../events/bloc/event_bloc.dart';
import '../../invitations/bloc/invitation_bloc.dart';
import '../../login/bloc/auth_bloc.dart';
import '../../utils/firebase/firebase_upload_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEdit = false;
  String image = '';
  var controller = TextEditingController();

  @override
  void initState() {
    controller = TextEditingController(
        text: FirebaseAuth.instance.currentUser?.displayName ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
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
              leading: GestureDetector(
                onTap: () {
                  if (isEdit) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Discard Changes?"),
                        content: const Text("All changes will be deleted"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() => isEdit = false);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => isEdit = false);
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Icon(Icons.arrow_back),
              ),
              centerTitle: true,
              actions: [
                if (!isEdit)
                  GestureDetector(
                    onTap: () => setState(() => isEdit = true),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Save Changes?"),
                          content: const Text("All changes will be saved"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() => isEdit = false);
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.read<ProfileBloc>().add(
                                    ProfileUpdate(
                                      user: UserPlannier(
                                        name: controller.text,
                                        photo: image,
                                      ),
                                      onFinished: () {
                                        Navigator.pop(context);
                                        setState(() => isEdit = false);
                                      },
                                    ),
                                  ),
                              child: Text(
                                "Yes",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.done,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
              ],
              title: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: isEdit
                              ? const EdgeInsets.only(top: 20)
                              : EdgeInsets.zero,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 2,
                              ),
                              shape: BoxShape.circle),
                          child: state.user.photo != null
                              ? CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    state.user.photo!,
                                  ),
                                )
                              : const SizedBox(),
                        ),
                        if (isEdit)
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(top: 20),
                            child: FirebaseUploadImage(
                              image,
                              path: 'userProfile/',
                              onUploaded: (newUrl) {
                                setState(() => image = newUrl);
                              },
                              isLoading: () {},
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (!isEdit)
                      Text(
                        '${state.user.name}',
                        style: const TextStyle(
                            fontFamily: 'Northwell',
                            fontSize: 40,
                            color: Colors.white),
                      )
                    else
                      TextFormField(
                        controller: controller,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Northwell',
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      )
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Email'),
                                      Text(
                                        state.user.email ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  BlocBuilder<InvitationBloc, InvitationState>(
                                    builder: (context, st) {
                                      if (st is InvitationLoaded) {
                                        var invitationResponses = st.invitations
                                            .where((element) =>
                                                element.response !=
                                                Response.pending)
                                            .length;
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Responses'),
                                            RichText(
                                              text: TextSpan(
                                                text: invitationResponses
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        '/${st.invitations.length}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  BlocBuilder<EventBloc, EventState>(
                                    builder: (context, st) {
                                      if (st is EventLoaded) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Events'),
                                            Text(
                                              st.events.length.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  BlocBuilder<ToDoBloc, ToDoState>(
                                    builder: (context, st) {
                                      if (st is ToDoLoaded) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('To Do Lists'),
                                            Text(
                                              st.toDo.length.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: SizedBox(
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
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
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
