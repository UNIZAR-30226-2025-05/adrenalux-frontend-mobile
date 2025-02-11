import 'package:adrenalux_frontend_mobile/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/screens/auth/sign_up_screen.dart';
import 'package:adrenalux_frontend_mobile/widgets/textField.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/button.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart'; 

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submit() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await signIn(email, password);
      if (response['data']['token'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()), //HomeScreen
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No se recibió un token válido')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
          Container(
            width: double.infinity,
            height: screenSize.height / 3,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.transparent, theme.colorScheme.surface],
                  stops: [0.1, 0.7],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/portada_inicio_sesion.jpg',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06, vertical: screenSize.height * 0.02),
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.015),
                  Padding(
                    padding: EdgeInsets.only(left: screenSize.width * 0.05),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "¡Bienvenido!",
                        style: TextStyle(
                          fontSize: screenSize.height * 0.03,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.005),
                  Padding(
                    padding: EdgeInsets.only(left: screenSize.width * 0.05),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Introduzca sus credenciales",
                        style: TextStyle(
                          fontSize: screenSize.height * 0.02,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.06),

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
                  SizedBox(height: screenSize.height * 0.04),
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
                  "Iniciar sesión",
                  _submit,
                ),
                SizedBox(height: screenSize.height * 0.02),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  ),
                  child: Text(
                    "¿Aún no tienes una cuenta? Registrarse",
                    style: TextStyle(
                      fontSize: screenSize.height * 0.017,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
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
