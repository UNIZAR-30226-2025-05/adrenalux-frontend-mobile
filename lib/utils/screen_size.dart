import 'package:flutter/material.dart';

class ScreenSize {
  final double width;
  final double height;

  ScreenSize({required this.width, required this.height});

  factory ScreenSize.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ScreenSize(width: size.width, height: size.height);
  }
}