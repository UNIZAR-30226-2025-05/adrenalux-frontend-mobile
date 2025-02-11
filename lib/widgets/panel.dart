import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class Panel extends StatelessWidget {
  final double width;
  final double height;
  final bool hasSearchBar;
  final Widget? content;

  Panel({
    required this.width,
    required this.height,
    this.hasSearchBar = false,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceBright,
            theme.colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), 
          ),
        ],
      ),
      child: Column(
        children: [
          if (hasSearchBar)
            Container(
              height: 50, 
              color: Colors.transparent, 
              child: Center(child: Text('Search Bar Placeholder')), 
            ),
          if (content != null)
            Expanded(child: content!), 
        ],
      ),
    );
  }
}