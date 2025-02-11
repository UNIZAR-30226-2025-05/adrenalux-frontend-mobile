import 'package:adrenalux_frontend_mobile/screens/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/textField.dart';
import 'package:adrenalux_frontend_mobile/widgets/button.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart'; 

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _submit() async {
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmedPassword = _confirmPasswordController.text.trim();

    try {
      final response = await signUp(username, email, password, confirmedPassword);

      if (response['status']['httpCode'] == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response['message'] ?? 'Registro fallido'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    final textColor = theme.textTheme.titleSmall?.color ?? Colors.black;
    final backgroundColor = theme.colorScheme.surface;
    final screenSize = ScreenSize.of(context); // Usa la clase ScreenSize

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06, vertical: screenSize.height * 0.02),
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.05),
                  Text(
                    "¡Conecta con nosotros!",
                    style: TextStyle(
                      fontSize: screenSize.height * 0.03, // Usa screenSize para el tamaño de fuente
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  Text(
                    "Regístrate para comenzar a jugar",
                    style: TextStyle(
                      fontSize: screenSize.height * 0.02, // Usa screenSize para el tamaño de fuente
                      color: textColor.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.05),

                  // Campo Nombre de usuario
                  TextFieldCustom(
                    controller: _usernameController,
                    labelText: 'Nombre de usuario',
                    iconText: Icons.account_circle,
                    obscureText: false,
                    validator: (_) => null,
                  ),
                  SizedBox(height: screenSize.height * 0.02),

                  // Campo Correo electrónico
                  TextFieldCustom(
                    controller: _emailController,
                    labelText: 'Correo electrónico',
                    iconText: Icons.alternate_email,
                    obscureText: false,
                    validator: (_) => null,
                  ),
                  SizedBox(height: screenSize.height * 0.02),

                  // Campo Contraseña
                  TextFieldCustom(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    iconText: Icons.vpn_key,
                    obscureText: true,
                    validator: (_) => null,
                  ),
                  SizedBox(height: screenSize.height * 0.02),

                  // Campo Confirmar Contraseña
                  TextFieldCustom(
                    controller: _confirmPasswordController,
                    labelText: 'Confirma la contraseña',
                    iconText: Icons.verified_user,
                    obscureText: true,
                    validator: (_) => null,
                  ),
                  SizedBox(height: screenSize.height * 0.05),
                ],
              ),
            ),
          ),

          // Botón de registro
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06, vertical: screenSize.height * 0.02),
            child: Column(
              children: [
                textButton(
                  context,
                  true,
                  "Registrarse",
                  _submit,
                ),
                SizedBox(height: screenSize.height * 0.02),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  ),
                  child: Text(
                    "¿Ya tienes una cuenta? Iniciar Sesión",
                    style: TextStyle(
                      fontSize: screenSize.height * 0.017, 
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  "© 2025 AdrenaLux. All Right Reserved",
                  style: TextStyle(
                    fontSize: screenSize.height * 0.015,
                    color: textColor.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
