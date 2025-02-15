import 'package:flutter/material.dart';

class ScreenSize {
  final double width;
  final double height;
  final double appBarHeight;

  ScreenSize({required this.width, required this.height, required this.appBarHeight});

  factory ScreenSize.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ScreenSize(width: size.width, height: size.height, appBarHeight: size.height / 13);  
  }
}