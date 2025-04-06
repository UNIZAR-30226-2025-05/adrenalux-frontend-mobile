import 'package:adrenalux_frontend_mobile/screens/auth/sign_in_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/textField.dart';
import 'package:adrenalux_frontend_mobile/widgets/button.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late ApiService apiService;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _emailError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false); 
    _emailController.addListener(_clearEmailError);
  }

  void _clearEmailError() {
    if (_emailError != null) setState(() => _emailError = null);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final result = await apiService.signUp(
        _nameController.text.trim(),
        _lastnameController.text.trim(),
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _confirmPasswordController.text.trim(),
      );

      if (result['statusCode'] == 201) {
        await apiService.signIn(_emailController.text.trim(), _passwordController.text.trim());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      } else {
        showCustomSnackBar(type: SnackBarType.error, message: result['errorMessage']);
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
                    SizedBox(height: screenSize.height * 0.125),
                    Text(
                      AppLocalizations.of(context)!.connectWithUs,
                      style: TextStyle(
                        fontSize: screenSize.height * 0.03,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    Text(
                      AppLocalizations.of(context)!.signUpMsg,
                      style: TextStyle(
                        fontSize: screenSize.height * 0.02,
                        color: textColor.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenSize.height * 0.06),
                    TextFieldCustom(
                      key: Key('name-field'),
                      controller: _nameController,
                      labelText: AppLocalizations.of(context)!.name,
                      iconText: Icons.person,
                      obscureText: false,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.nameRequired;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    TextFieldCustom(
                      key: Key('lastname-field'),
                      controller: _lastnameController,
                      labelText: AppLocalizations.of(context)!.lastname,
                      iconText: Icons.badge,
                      obscureText: false,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.lastnameRequired;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    TextFieldCustom(
                      key: Key('username-field'),
                      controller: _usernameController,
                      labelText: AppLocalizations.of(context)!.username,
                      iconText: Icons.person,
                      obscureText: false,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.usernameRequired;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.02),
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
                    SizedBox(height: screenSize.height * 0.02),
                    TextFieldCustom(
                      key: Key('confirm-password-field'),
                      controller: _confirmPasswordController,
                      labelText: AppLocalizations.of(context)!.password2,
                      iconText: Icons.verified_user,
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.confirmPasswordRequired;
                        }
                        if (value != _passwordController.text) {
                          return AppLocalizations.of(context)!.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.05),
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
                        AppLocalizations.of(context)!.signUp,
                        _submit,
                        key: Key('sign-up-button'),
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
                  key: Key('redirect-sign-in'),
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.redirectSignIn,
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