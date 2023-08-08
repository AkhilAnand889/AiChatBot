import 'package:flutter/material.dart';

class BlendingSnackbar extends SnackBar {
  BlendingSnackbar({
    required String message,
    required Color backgroundColor,
    String? actionLabel,
    VoidCallback? onPressed,
  }) : super(
          behavior: SnackBarBehavior.fixed,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 3),
          action: onPressed != null
              ? SnackBarAction(
                  label: actionLabel ?? 'CLOSE',
                  textColor: Colors.white,
                  onPressed: onPressed,
                )
              : null,
          backgroundColor: backgroundColor,
        );
}

class SnackbarUtils {
  static void showSuccessSnackbar(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.green);
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.red);
  }

  static void _showSnackbar(BuildContext context, String message, Color backgroundColor) {
    final snackBar = BlendingSnackbar(
      message: message,
      backgroundColor: backgroundColor,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
