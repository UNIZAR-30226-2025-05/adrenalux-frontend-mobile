import 'package:adrenalux_frontend_mobile/screens/auth/sign_in_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/textField.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/widgets/button.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart'; 
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        await signIn(email, password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      } else {
        showCustomSnackBar(type: SnackBarType.error, message: result['errorMessage'], duration:  10);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
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
                    AppLocalizations.of(context)!.connect_with_us,
                    style: TextStyle(
                      fontSize: screenSize.height * 0.03, 
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  Text(
                    AppLocalizations.of(context)!.sign_up_msg,
                    style: TextStyle(
                      fontSize: screenSize.height * 0.02, 
                      color: textColor.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.06),

                  TextFieldCustom(
                    controller: _nameController,
                    labelText: AppLocalizations.of(context)!.name,
                    iconText: Icons.person,
                    obscureText: false,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  TextFieldCustom(
                    controller: _lastnameController,
                    labelText: AppLocalizations.of(context)!.lastname,
                    iconText: Icons.badge,
                    obscureText: false,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  TextFieldCustom(
                    controller: _usernameController,
                    labelText: AppLocalizations.of(context)!.username,
                    iconText: Icons.person,
                    obscureText: false,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  TextFieldCustom(
                    controller: _emailController,
                    labelText: AppLocalizations.of(context)!.email,
                    iconText: Icons.alternate_email,
                    obscureText: false,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  TextFieldCustom(
                    controller: _passwordController,
                    labelText: AppLocalizations.of(context)!.password,
                    iconText: Icons.vpn_key,
                    obscureText: true,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  TextFieldCustom(
                    controller: _confirmPasswordController,
                    labelText: AppLocalizations.of(context)!.password2,
                    iconText: Icons.verified_user,
                    obscureText: true,
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
                  AppLocalizations.of(context)!.sign_up,
                  _submit,
                ),
                SizedBox(height: screenSize.height * 0.02),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.redirect_sign_in,
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
                  AppLocalizations.of(context)!.rights,
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
