import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/constants/keys.dart';

enum SnackBarType { success, error, info }

class CustomSnackBar extends StatefulWidget {
  static OverlayEntry? currentOverlayEntry;
  final SnackBarType type;
  final String message;
  final VoidCallback? onDismissed;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CustomSnackBar({
    required this.type,
    required this.message,
    this.actionLabel,
    this.onAction,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    _screenHeight = mediaQuery.size.height;
    _offsetY = _screenHeight * 0.02;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    Color backgroundColor = Colors.grey;
    Icon icon = const Icon(Icons.info);

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

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 800),
      child: Transform.translate(
        offset: Offset(0, _offsetY),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenSize.width * 0.9,
            padding: EdgeInsets.symmetric(
              vertical: screenSize.height * 0.01,
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
                      fontSize: screenSize.width * 0.04,
                    ),
                  ),
                ),
                if (widget.actionLabel != null)
                  TextButton(
                    onPressed: () {
                      widget.onAction?.call();
                      _dismiss();
                    },
                    child: Text(
                      widget.actionLabel!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenSize.width * 0.035,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: _dismiss,
                  icon: Icon(Icons.close, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _dismiss() {
    if (_isDismissing) return;

    _isDismissing = true;
    setState(() {
      _offsetY = -_screenHeight * 0.5;
      _opacity = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        widget.onDismissed?.call();
      }
    });
  }

  void fadeOut() {
    _dismiss();
  }
}

void showCustomSnackBar({
  required SnackBarType type,
  required String message,
  int duration = 5,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlayState = navigatorKey.currentState?.overlay;

  if (overlayState == null) return;

  void safeRemoveOverlay() {
    if (CustomSnackBar.currentOverlayEntry?.mounted == true) {
      CustomSnackBar.currentOverlayEntry?.remove();
    }
    CustomSnackBar.currentOverlayEntry = null;
  }

  safeRemoveOverlay();

  late final OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: ScreenSize.of(context).height * 0.05,
      left: ScreenSize.of(context).width * 0.05,
      right: ScreenSize.of(context).width * 0.05,
      child: CustomSnackBar(
        type: type,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismissed: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
          CustomSnackBar.currentOverlayEntry = null;
        },
      ),
    ),
  );

  overlayState.insert(overlayEntry);
  CustomSnackBar.currentOverlayEntry = overlayEntry;

  if (actionLabel == null) {
    Future.delayed(Duration(seconds: duration), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
      CustomSnackBar.currentOverlayEntry = null;
    });
  }
}