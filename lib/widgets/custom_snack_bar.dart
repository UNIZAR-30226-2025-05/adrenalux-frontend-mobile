import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';

enum SnackBarType { success, error, info }

class CustomSnackBar extends StatefulWidget {
  final SnackBarType type;
  final String message;
  final VoidCallback? onDismissed;

  const CustomSnackBar({
    required this.type,
    required this.message,
    this.onDismissed,
    Key? key,
  }) : super(key: key);

  @override
  _CustomSnackBarState createState() => _CustomSnackBarState();
}

class _CustomSnackBarState extends State<CustomSnackBar> {
  double _opacity = 1.0;
  double _offsetY = 0;
  bool _isDismissing = false;
  double _screenHeight = 0;
  double _maxOffset = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    _screenHeight = mediaQuery.size.height;
    _offsetY = _screenHeight * 0.02;
    _maxOffset = _screenHeight * 0.3;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);

    Color backgroundColor;
    Icon icon;

    switch (widget.type) {
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

    return GestureDetector(
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 800),
        child: Transform.translate(
          offset: Offset(0, _offsetY),
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
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: screenSize.width * 0.04
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isDismissing) return;
    
    final delta = details.primaryDelta ?? 0;
    if (delta < 0) {
      setState(() {
        _offsetY += delta * 1.5; 
        _opacity = 1 - (_offsetY.abs() / _maxOffset).clamp(0.0, 1.0);
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isDismissing) return;
    
    if (_offsetY.abs() > _screenHeight * 0.1) { 
      _dismiss();
    } else {
      setState(() {
        _offsetY = _screenHeight * 0.02; 
        _opacity = 1.0;
      });
    }
  }

  void _dismiss() {
    if (_screenHeight <= 0) return;
    
    _isDismissing = true;
    setState(() {
      _offsetY = -_screenHeight * 0.5;
      _opacity = 0.0;
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onDismissed?.call();
    });
  }
  void fadeOut() {
    _dismiss();
  }
}

void showCustomSnackBar(BuildContext context, SnackBarType type, String message, int duration) {
  final screenSize = ScreenSize.of(context);
  final overlay = Overlay.of(context);
  final GlobalKey<_CustomSnackBarState> snackBarKey = GlobalKey<_CustomSnackBarState>();

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: screenSize.height * 0.05,
      left: screenSize.width * 0.05,
      right: screenSize.width * 0.05,
      child: CustomSnackBar(
        key: snackBarKey,
        type: type,
        message: message,
        onDismissed: () {
          if (overlayEntry.mounted) overlayEntry.remove();
        },
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: duration - 1), () {
    snackBarKey.currentState?.fadeOut();
  });

  Future.delayed(Duration(seconds: duration), () {
    if (overlayEntry.mounted) overlayEntry.remove();
  });
}
