import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/colors.dart';
import '../../utils/platform_specific_dialog.dart';
import '../bloc/auth_bloc.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isObscure = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Theme.of(context).colorScheme.background,
      child: Scaffold(
        appBar: AppBar(),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              setState(() => isLoading = false);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child: Text(
                          'Plannier',
                          style: TextStyle(
                              fontFamily: 'Northwell',
                              fontSize: 60,
                              color: PlannerieColors.primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          controller: email,
                          style: GoogleFonts.dmSans(color: Colors.black),
                          decoration: const InputDecoration(
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none,
                            label: Text('Email'),
                            prefixIcon: FaIcon(FontAwesomeIcons.user),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 30,
                              minHeight: 25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: PlannerieColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            setState(() => isLoading = true);
                            context.read<AuthBloc>().add(
                                  AuthResetPassword(
                                    email: email.text.trim(),
                                    onFinished: () {
                                      setState(() => isLoading = false);
                                      showDialog(
                                        context: context,
                                        builder: (ctx) =>
                                            PlatformSpecificDialog(
                                          title: const Text('Success'),
                                          content: const Text(
                                              'Verify your email to finish resetting your password'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const LoginScreen(),
                                                ),
                                              ),
                                              child: const Text('Okay'),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                          },
                          child: const Text('Reset Password'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
