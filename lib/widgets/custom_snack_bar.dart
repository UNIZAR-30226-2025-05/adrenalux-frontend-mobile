import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:adrenalux_frontend_mobile/constants/keys.dart';

enum SnackBarType { success, error, info }

void showCustomSnackBar({
  required SnackBarType type,
  required String message,
  int? duration, 
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final context = navigatorKey.currentState?.overlay?.context;
  if (context == null) return;

  Color backgroundColor;
  Icon icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = Colors.green;
      icon = const Icon(Icons.check, color: Colors.white);
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red;
      icon = const Icon(Icons.error, color: Colors.white);
      break;
    case SnackBarType.info:
      backgroundColor = Colors.blue;
      icon = const Icon(Icons.info, color: Colors.white);
      break;
  }

  late final Flushbar flush;
  flush = Flushbar(
    message: message,
    icon: icon,
    backgroundColor: backgroundColor,
    margin: const EdgeInsets.all(8.0),
    borderRadius: BorderRadius.circular(8.0),
    flushbarPosition: FlushbarPosition.TOP,
    duration: duration != null ? Duration(seconds: duration) : null, // Duración opcional
    mainButton: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (actionLabel != null)
          TextButton(
            onPressed: () {
              onAction?.call();
              flush.dismiss();
            },
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => flush.dismiss(),
        ),
      ],
    ),
  );

  flush.show(context);
}
