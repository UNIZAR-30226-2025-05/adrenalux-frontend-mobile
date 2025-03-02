import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PackAnimations {
  static Animate packOpeningAnimation(Widget child, bool isAnimating) {
    return child.animate(target: isAnimating ? 1 : 0)
      .shimmer(delay: 300.ms, duration: 1500.ms, angle: -0.5, color: Colors.white.withOpacity(0.6))
      .moveY(begin: 0, end: -10, duration: 2000.ms, curve: Curves.easeInOut)
      .then()
      .moveY(begin: -10, end: 0, duration: 2000.ms, curve: Curves.easeInOut)
      .then(delay: 100.ms)
      .scaleXY(begin: 1, end: 1.8, curve: Curves.easeOutBack, duration: 300.ms)
      .shake(hz: 4, offset: const Offset(0.4, 0.0), duration: 300.ms)
      .then()
      .scaleXY(begin: 1.8, end: 0.3, duration: 800.ms)
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
      .slideX(begin: 0, end: 2.0, curve: Curves.easeIn, duration: 200.ms)
      .fadeOut(duration: 400.ms);
  }

  static Animate megaLuxurySpecialAnimation({
    required Widget child,
    required String teamLogo,
    required String position,
    required BuildContext context,
    required VoidCallback onAnimationStart,
    required VoidCallback onAnimationEnd,
  }) {
    return Animate(
      delay: 300.ms,
      onPlay: (controller) {
        onAnimationStart();
        controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            onAnimationEnd();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Animate(
            effects: [
              FadeEffect(begin: 0, end: 1, duration: 1000.ms),
              ScaleEffect(begin: const Offset(0.3, 0.3), curve: Curves.easeOutBack),
            ],
            child: Center(child: CachedNetworkImage(imageUrl: teamLogo, width: 200, height: 200)),
          ).then(delay: 1500.ms).fadeOut(duration: 500.ms),
          Animate(
            delay: 2500.ms,
            effects: [
              FadeEffect(begin: 0, end: 1, duration: 800.ms),
              ScaleEffect(begin: const Offset(0.5, 0.5), curve: Curves.easeOutCubic),
            ],
            child: Center(
              child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 15, spreadRadius: 5)]),
                  child: Text(position, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amber[100])),
              ),
            ),
          ).then(delay: 1500.ms).fadeOut(duration: 500.ms),
          Animate(
            delay: 4500.ms,
            effects: [
              FadeEffect(begin: 0, end: 1, duration: 1500.ms),
              ScaleEffect(begin: const Offset(0.2, 0.2), curve: Curves.easeOutCirc),
              ShimmerEffect(duration: 2500.ms, color: Colors.amber.withOpacity(0.9), angle: 0.35),
            ],
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}
