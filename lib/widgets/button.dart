import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart'; 

SizedBox textButton(BuildContext context, bool type, 
                    String text, Function() action) {

  final screenSize = ScreenSize.of(context); 
  final themeProvider = Provider.of<ThemeProvider>(context);
  final theme = themeProvider.currentTheme;

  return SizedBox(
    width: screenSize.width * 0.8, 
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withAlpha(140),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary,
          width: type ? 0 : 1.25,
        ),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.015), 
        ),
        onPressed: action,
        child: Text(
          text,
          style: TextStyle(
            fontSize: screenSize.height * 0.025, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}
