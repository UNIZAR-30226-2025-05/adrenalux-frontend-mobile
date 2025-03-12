import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class AchievementNotification {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.emoji_events,
    Color iconColor = Colors.amber,
    int durationSeconds = 3,
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: Icon(
        icon,
        color: iconColor,
        size: 32,
      ),
      duration: Duration(seconds: durationSeconds),
      flushbarPosition: FlushbarPosition.TOP,
      margin: EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      backgroundGradient: LinearGradient(
        colors: [
          Theme.of(context).primaryColorDark,
          Theme.of(context).primaryColor,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(0, 2),
          blurRadius: 6,
        )
      ],
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.easeInOutBack,
      reverseAnimationCurve: Curves.easeInOutBack,
      titleText: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.1,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      padding: EdgeInsets.all(20),
      leftBarIndicatorColor: Colors.amber,
      shouldIconPulse: true,
    ).show(context);
  }
}