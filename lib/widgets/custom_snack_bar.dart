import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart'; 

enum SnackBarType { success, error, info }

class CustomSnackBar extends StatelessWidget {
  final SnackBarType type;
  final String message;

  const CustomSnackBar({
    required this.type,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    Color backgroundColor;
    Icon icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        icon = Icon(Icons.check, color: Colors.white);
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red;
        icon = Icon(Icons.error, color: Colors.white);
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue;
        icon = Icon(Icons.info, color: Colors.white);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        width: screenSize.width * 0.9,
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
          horizontal: screenSize.width * 0.05,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor.withOpacity(0.8),
              backgroundColor.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            icon,
            SizedBox(width: screenSize.width * 0.02),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: screenSize.width * 0.04),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showCustomSnackBar(BuildContext context, SnackBarType type, String message, int duration) {
  final screenSize = ScreenSize.of(context);
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: screenSize.height * 0.05, 
      left: screenSize.width * 0.05,
      right: screenSize.width * 0.05,
      child: CustomSnackBar(type: type, message: message),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: duration), () {
    overlayEntry.remove();
  });
}
