import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/screens/auth/sign_up_screen.dart';
import 'package:adrenalux_frontend_mobile/widgets/textField.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/button.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (_emailError != null) {
        setState(() {
          _emailError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await signIn(email, password);
      if (response['data']['token'] != null) {
        resetUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      } else {
        setState(() {
          _emailError = AppLocalizations.of(context)!.tokenNotReceived;
        });
        _formKey.currentState!.validate();
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _emailError =
            AppLocalizations.of(context)!.connectionError(errorMessage);
      });
      _formKey.currentState!.validate();
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
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.06,
                vertical: screenSize.height * 0.02,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: screenSize.height * 0.015),
                    Padding(
                      padding: EdgeInsets.only(left: screenSize.width * 0.05),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.welcome,
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
                          AppLocalizations.of(context)!.credentials,
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
                      labelText: AppLocalizations.of(context)!.email,
                      iconText: Icons.alternate_email,
                      obscureText: false,
                      validator: (value) {
                        if (_emailError != null) {print(_emailError); return _emailError;}
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.emailRequired;
                        }
                        if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return AppLocalizations.of(context)!.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    TextFieldCustom(
                      controller: _passwordController,
                      labelText: AppLocalizations.of(context)!.password,
                      iconText: Icons.vpn_key,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.passwordRequired;
                        }
                        if (value.length < 6) {
                          return AppLocalizations.of(context)!.passwordMinLength;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.04),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.06,
              vertical: screenSize.height * 0.02,
            ),
            child: Column(
              children: [
                textButton(
                  context,
                  true,
                  AppLocalizations.of(context)!.sign_in,
                  _submit,
                ),
                SizedBox(height: screenSize.height * 0.02),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.redirect_sign_up,
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
