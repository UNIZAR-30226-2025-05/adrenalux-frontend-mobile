import 'package:flutter/material.dart';

class AppGradients {
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.7],
  );

  static const LinearGradient scoreBackground = LinearGradient(
    colors: [Color(0x334D4D4D), Color(0x0AFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );


  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFFA53D), Color(0xFFF57C00)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient victoryGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    stops: [0.1, 0.9],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBackground = LinearGradient(
    colors: [Color(0xFF121212), Color(0xFF2D2D2D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}