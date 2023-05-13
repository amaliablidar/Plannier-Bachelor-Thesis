import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plannier/events/bloc/event_bloc.dart';
import 'package:plannier/home/screens/home_screen.dart';
import 'package:plannier/profile/bloc/profile_bloc.dart';
import 'package:plannier/to_do/bloc/to_do_bloc.dart';
import 'package:plannier/utils/colors.dart';
import 'package:plannier/utils/firebase/firebase_storage.dart';
import 'package:provider/provider.dart';

import 'invitations/bloc/invitation_bloc.dart';
import 'login/bloc/auth_bloc.dart';
import 'login/screens/login_screen.dart';
import 'main_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: PlannerieColors.primary, // Color for Android
        statusBarBrightness:
            Brightness.dark // Dark == white status bar -- for IOS.
        ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseStorageService>(
      create: (context) => FirebaseStorageService(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(),
          ),
          BlocProvider(
            create: (context) => ToDoBloc(),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primaryColor: PlannerieColors.primary,
            scaffoldBackgroundColor: Colors.grey.shade100,
            textTheme: TextTheme(
              titleMedium: GoogleFonts.dmSans(
                color: Colors.black,
              ),
              titleSmall: GoogleFonts.dmSans(color: Colors.black, fontSize: 20),
            ),
            colorScheme: ColorScheme(
                secondary: PlannerieColors.secondary,
                onBackground: Colors.grey.shade200,
                brightness: Brightness.light,
                onError: Colors.white,
                onSecondary: Colors.white,
                background: Colors.grey.shade200,
                onSurface: PlannerieColors.primaryLight,
                surface: Colors.white,
                primary: PlannerieColors.primary,
                onPrimary: Colors.white,
                error: Colors.red),
          ),
          debugShowCheckedModeBanner: false,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return MultiBlocProvider(providers: [
                  BlocProvider(
                    create: (context) => EventBloc(),
                  ),
                  BlocProvider(
                    create: (context) => InvitationBloc(),
                  ),
                ], child: const MainScreen());
              } else {
                return const LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
