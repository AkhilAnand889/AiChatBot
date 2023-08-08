import 'package:aibot/Screens/Auth.dart';
import 'package:aibot/Screens/appbarTitle.dart';
import 'package:aibot/utils/colors.dart';
import 'package:flutter/material.dart';


class FadeScaleRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  FadeScaleRoute({required this.builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Interval(0.0, 0.5, curve: Curves.easeOut),
                ),
              ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Interval(0.5, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: child,
              ),
            );
          },
        );
}


class YourCurrentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                FadeScaleRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).colorScheme.background,
          ),
        ],
        toolbarHeight: 70,
        title: AppBarTitle(),
        backgroundColor: ColorSets.botBackgroundColor,
      ),
    );
  }
}




