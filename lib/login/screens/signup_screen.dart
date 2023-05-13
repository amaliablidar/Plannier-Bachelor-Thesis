import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plannier/login/screens/login_screen.dart';

import '../../main_screen.dart';
import '../../utils/colors.dart';
import '../../utils/firebase/firebase_upload_image.dart';
import '../../utils/platform_specific_dialog.dart';
import '../bloc/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isObscure = true;
  IconData icon = FontAwesomeIcons.eye;
  bool isLoading = false;
  String image = '';

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
                  child: SingleChildScrollView(
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
                        FirebaseUploadImage(
                          image,
                          path: 'userProfile/',
                          onUploaded: (newUrl) {
                            setState(() => image = newUrl);
                          },
                          isLoading: () {},
                        ),
                        const SizedBox(height: 30),
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
                                  controller: firstName,
                                  style:
                                      GoogleFonts.dmSans(color: Colors.black),
                                  decoration: const InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    label: Text('First Name'),
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
                                  controller: lastName,
                                  style:
                                      GoogleFonts.dmSans(color: Colors.black),
                                  decoration: const InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    label: Text('Last Name'),
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
                                  controller: email,
                                  style:
                                      GoogleFonts.dmSans(color: Colors.black),
                                  decoration: const InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    label: Text('Email'),
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
                                  style:
                                      GoogleFonts.dmSans(color: Colors.black),
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
                                  AuthSignup(
                                    firstName: firstName.text.trim(),
                                    lastName: lastName.text.trim(),
                                    email: email.text.trim(),
                                    password: password.text.trim(),
                                    onFinished: () {
                                      setState(() => isLoading = false);
                                      showDialog(
                                        context: context,
                                        builder: (ctx) =>
                                            PlatformSpecificDialog(
                                          title: const Text('Success'),
                                          content: const Text(
                                              'Login into your account to continue'),
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
                                    imageUrl: image,
                                  ),
                                );
                          },
                          child: const Text('Sign up'),
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
