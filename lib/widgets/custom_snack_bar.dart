import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';

enum SnackBarType { success, error, info }

class CustomSnackBar extends StatefulWidget {
  final SnackBarType type;
  final String message;

  const CustomSnackBar({
    required this.type,
    required this.message,
    Key? key,
  }) : super(key: key);

  @override
  _CustomSnackBarState createState() => _CustomSnackBarState();
}

class _CustomSnackBarState extends State<CustomSnackBar> {
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    Color backgroundColor;
    Icon icon;

    switch (widget.type) {
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

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      child: Material(
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
                  widget.message,
                  style: TextStyle(color: Colors.white, fontSize: screenSize.width * 0.04),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fadeOut() {
    setState(() {
      _opacity = 0.0;
    });
  }
}

void showCustomSnackBar(BuildContext context, SnackBarType type, String message, int duration) {
  final screenSize = ScreenSize.of(context);
  final overlay = Overlay.of(context);
  final GlobalKey<_CustomSnackBarState> snackBarKey = GlobalKey<_CustomSnackBarState>();

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: screenSize.height * 0.05,
      left: screenSize.width * 0.05,
      right: screenSize.width * 0.05,
      child: CustomSnackBar(
        key: snackBarKey,
        type: type,
        message: message,
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: duration - 1), () {
    snackBarKey.currentState?.fadeOut();
  });

  Future.delayed(Duration(seconds: duration), () {
    overlayEntry.remove();
  });
}
