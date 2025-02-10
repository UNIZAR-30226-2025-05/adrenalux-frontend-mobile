import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';

class TextFieldCustom extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData iconText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const TextFieldCustom({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.labelText,
    required this.iconText,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    final screenSize = ScreenSize.of(context);

    Color fillColor = theme.inputDecorationTheme.fillColor ??
        (themeProvider.isDarkTheme
            ? const Color.fromARGB(255, 50, 50, 50)
            : const Color.fromARGB(255, 240, 240, 240));

    Color labelColor = theme.inputDecorationTheme.labelStyle?.color ??
        (themeProvider.isDarkTheme ? Colors.white70 : Colors.black87);

    Color borderColor = theme.dividerColor;

    double iconSize = screenSize.height * 0.03;
    double fontSize = screenSize.height * 0.018;
    double paddingVertical = screenSize.height * 0.012;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500, // Para evitar que en tablets el campo sea muy ancho
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Bordes redondeados más responsivos
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.secondary,
              ),
            ),
            fillColor: fillColor,
            filled: true,
            labelText: labelText,
            labelStyle: TextStyle(
              color: labelColor,
              fontSize: fontSize,
            ),
            prefixIcon: Icon(iconText, color: labelColor, size: iconSize),
            contentPadding: EdgeInsets.symmetric(vertical: paddingVertical, horizontal: 15),
          ),
          validator: validator,
        ),
      ),
    );
  }
}
