import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PackAnimations {
  static const double _rotationAngle = 2 * 3.1416; 

  static Animate packOpeningAnimation(Widget child, bool isAnimating) {
    return child.animate(target: isAnimating ? 1 : 0)
      .shimmer(
        delay: 300.ms,
        duration: 1500.ms,
        angle: -0.5,
        color: Colors.white.withOpacity(0.6),
      )
      .moveY(begin: 0, end: -10, duration: 2000.ms, curve: Curves.easeInOut)
      .then()
      .moveY(begin: -10, end: 0, duration: 2000.ms, curve: Curves.easeInOut)
      .then(delay: 100.ms)
      .scaleXY(
        begin: 1,
        end: 1.8,
        curve: Curves.easeOutBack,
        duration: 300.ms,
      )
      .shake(
        hz: 4,
        offset: const Offset(0.4, 0.0),
        duration: 300.ms,
      )
      .then()
      .rotate(
        begin: 0,
        end: _rotationAngle,
        duration: 800.ms,
        curve: Curves.easeInOutCubic,
      )
      .scaleXY(
        begin: 1.8,
        end: 0.3,
        duration: 800.ms,
      )
      .fade(begin: 1, end: 0.3, duration: 400.ms)
      .fadeOut(duration: 600.ms);
  }

  static Animate cardFloatAnimation(Widget child) {
    return child.animate(onPlay: (controller) => controller.repeat())
      .moveY(begin: 0, end: -15, duration: 2000.ms, curve: Curves.easeInOut)
      .then()
      .moveY(begin: -15, end: 0, duration: 2000.ms, curve: Curves.easeInOut);
  }

  static Animate cardExitAnimation(Widget child) {
    return child.animate()
      .slideX(begin: 0, end: 2.0, curve: Curves.easeIn)
      .rotate(begin: 0, end: 0.15, curve: Curves.easeIn)
      .fadeOut(duration: 500.ms);
  }
}