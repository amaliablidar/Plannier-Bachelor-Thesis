import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plannier/invitations/bloc/invitation_bloc.dart';
import 'package:plannier/login/bloc/auth_bloc.dart';
import 'package:plannier/login/screens/forgot_password_screen.dart';
import 'package:plannier/login/screens/signup_screen.dart';
import 'package:plannier/utils/colors.dart';
import 'package:plannier/utils/platform_specific_dialog.dart';

import '../../events/bloc/event_bloc.dart';
import '../../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isObscure = true;
  IconData icon = FontAwesomeIcons.eye;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Theme.of(context).colorScheme.background,
      child: Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              setState(() => isLoading = false);
              showDialog(
                context: context,
                builder: (_) => PlatformSpecificDialog(
                  title: const Text(
                    'Error',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    state.message,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthReload());

                        Navigator.pop(context);
                      },
                      child: const Text('Okay'),
                    )
                  ],
                ),
              );
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
                      Form(
                        child: Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
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
                            const SizedBox(height: 10),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextFormField(
                                controller: password,
                                obscureText: isObscure,
                                style: GoogleFonts.dmSans(color: Colors.black),
                                decoration: InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  label: const Text('Password'),
                                  suffix: GestureDetector(
                                    child: FaIcon(
                                      icon,
                                      size: 20,
                                    ),
                                    onTap: () => setState(
                                      () {
                                        isObscure = !isObscure;
                                        if (isObscure) {
                                          icon = FontAwesomeIcons.eye;
                                        } else {
                                          icon = FontAwesomeIcons.eyeSlash;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text('Forgot Password?'),
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
                                  AuthLogin(
                                    email: email.text.trim(),
                                    password: password.text.trim(),
                                    onFinished: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MultiBlocProvider(
                                          providers: [
                                            BlocProvider(
                                              create: (context) => EventBloc(),
                                            ),
                                            BlocProvider(
                                              create: (context) => InvitationBloc(),
                                            ),
                                          ],
                                          child: const MainScreen(),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                          },
                          child: const Text('Login'),
                        ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SignupScreen())),
                  child: const Text.rich(
                    TextSpan(
                      text: 'No Account? ',
                      children: [
                        TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: PlannerieColors.primary))
                      ],
                    ),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w400),
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
