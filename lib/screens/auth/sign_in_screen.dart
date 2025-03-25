import 'package:adrenalux_frontend_mobile/screens/auth/sign_up_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/textField.dart';
import 'package:adrenalux_frontend_mobile/widgets/button.dart';
import 'package:provider/provider.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearEmailError);
  }

  void _clearEmailError() {
    if (_emailError != null) {
      setState(() => _emailError = null);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final apiService = Provider.of<ApiService>(context, listen: false);
    
    try {
      final response = await apiService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (response['data']['token'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      }
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _emailError = errorMsg);
      _formKey.currentState!.validate();
    } finally {
      setState(() => _isLoading = false);
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
      resizeToAvoidBottomInset: false, 
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: screenSize.height / 3,
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Colors.transparent, theme.colorScheme.surface],
                stops: [0.1, 0.7],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height)),
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
                      key: Key('email-field'),
                      controller: _emailController,
                      labelText: AppLocalizations.of(context)!.email,
                      iconText: Icons.alternate_email,
                      obscureText: false,
                      validator: (value) {
                        if (_emailError != null) return _emailError;
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.emailRequired;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                          return AppLocalizations.of(context)!.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    TextFieldCustom(
                      key: Key('password-field'),
                      controller: _passwordController,
                      labelText: AppLocalizations.of(context)!.password,
                      iconText: Icons.vpn_key,
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.passwordRequired;
                        }
                        if (value!.length < 6) {
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
                _isLoading 
                  ? CircularProgressIndicator()
                  : textButton(
                      context,
                      true,
                      AppLocalizations.of(context)!.sign_in,
                      _submit,
                      key: const Key('login-button'),
                    ),
                SizedBox(height: screenSize.height * 0.02),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("O"),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.02),
                OutlinedButton.icon(
                  icon: Image.asset('assets/google_icon.png', height: 24),
                  label: Text("Iniciar sesión con Google"),
                  onPressed: () => GoogleAuthService.signInWithGoogle(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: Colors.grey),
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
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