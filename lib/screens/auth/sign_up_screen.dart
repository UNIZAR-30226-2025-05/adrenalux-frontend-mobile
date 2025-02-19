import 'package:adrenalux_frontend_mobile/screens/auth/sign_in_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _submit() async {
    final String username = _usernameController.text.trim();
    final String name = _nameController.text.trim();
    final String lastname = _lastnameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmedPassword = _confirmPasswordController.text.trim();

    try {
      final result = await signUp(name, lastname, username, email, password, confirmedPassword);
      
      if (result['statusCode'] == 201) {
        // Registro exitoso
        await signIn(email, password);
        SocketService().initialize(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      } 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    final textColor = theme.textTheme.titleSmall?.color ?? Colors.black;
    final backgroundColor = theme.colorScheme.surface;
    final screenSize = ScreenSize.of(context); 

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06, vertical: screenSize.height * 0.02),
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.125),
                  Text(
                    "¡Conecta con nosotros!",
                    style: TextStyle(
                      fontSize: screenSize.height * 0.03, 
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  Text(
                    "Regístrate para comenzar a jugar",
                    style: TextStyle(
                      fontSize: screenSize.height * 0.02, 
                      color: textColor.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.06),

                  TextFieldCustom(
                    controller: _usernameController,
                    labelText: 'Nombre de usuario',
                    iconText: Icons.account_circle,
                    obscureText: false,
                    validator: (_) => null,
                  ),
                  SizedBox(height: screenSize.height * 0.02),

                  TextFieldCustom(
                    controller: _nameController,
                    labelText: 'Nombre',
                    iconText: Icons.person,
                    obscureText: false,
                    validator: (_) => null,
                  ),
                  SizedBox(height: screenSize.height * 0.02),

                  TextFieldCustom(
                    controller: _lastnameController,
                    labelText: 'Apellidos',
                    iconText: Icons.badge,
                    obscureText: false,
                    validator: (_) => null,
                  ),
                  SizedBox(height: screenSize.height * 0.02),

                  TextFieldCustom(
                    controller: _emailController,
                    labelText: 'Correo electrónico',
                    iconText: Icons.alternate_email,
                    obscureText: false,
                    validator: (_) => null,
                  ),
                  SizedBox(height: screenSize.height * 0.02),

                  TextFieldCustom(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    iconText: Icons.vpn_key,
                    obscureText: true,
                    validator: (_) => null,
                  ),
                  SizedBox(height: screenSize.height * 0.02),

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
