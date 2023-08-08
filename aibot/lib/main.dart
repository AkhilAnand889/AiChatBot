import 'package:aibot/Screens/Auth.dart';
import 'package:aibot/Screens/introScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ChatBot',
      home: FutureBuilder<bool>(
        future: _shouldShowIntro(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data! ? LoginScreen() : IntroPage();
          } else {
            return CircularProgressIndicator(); // Loading indicator
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<bool> _shouldShowIntro() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasLaunchedBefore = prefs.getBool('hasLaunchedBefore') ?? false;

    if (!hasLaunchedBefore) {
      prefs.setBool('hasLaunchedBefore', true);
    }

    return !hasLaunchedBefore;
  }
}
