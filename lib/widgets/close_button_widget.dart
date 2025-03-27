import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';

class CloseButtonWidget extends StatelessWidget {
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const CloseButtonWidget({
    super.key,
    this.size = 60.0,
    this.iconSize = 28.0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.close,
          color: theme.colorScheme.onPrimary,
          size: iconSize,
        ),
      ),
    );
  }
}