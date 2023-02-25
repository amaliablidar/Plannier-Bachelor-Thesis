import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plannier/utils/colors.dart';

import 'main_screen.dart';

Future main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: PlannerieColors.primary,
          scaffoldBackgroundColor: Colors.grey.shade100,
          textTheme: TextTheme(
            subtitle1: GoogleFonts.rajdhani(
              color: const Color(0xffffd5b9),
            ),
            subtitle2: GoogleFonts.rajdhani(
                color: const Color(0xffffd5b9), fontSize: 20),
          ),
          colorScheme: ColorScheme(
              secondary: PlannerieColors.secondary,
              onBackground: Colors.grey.shade200,
              brightness: Brightness.light,
              onError: Colors.white,
              onSecondary: Colors.grey.shade200,
              background: Colors.grey.shade200,
              onSurface: Colors.grey.shade200,
              surface: Colors.grey.shade200,
              primary: PlannerieColors.primary,
              onPrimary: Colors.grey.shade200,
              error: Colors.red)),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
