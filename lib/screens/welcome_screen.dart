import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _verticalAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _verticalAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    final nextScreen = null;
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    final screenSize = ScreenSize.of(context);

    return GestureDetector(
      onTap: _navigateToNextScreen,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6, color: theme.iconTheme.color),
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.08,
                vertical: screenSize.height * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    themeProvider.getLogo(),
                    width: screenSize.width * 0.75,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'AdrenaLux',
                    style: TextStyle(
                      fontSize: screenSize.height * 0.05,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.headlineMedium?.color,
                    ),
                  ),
                  Text(
                    'Trading Card Game',
                    style: TextStyle(
                      fontSize: screenSize.height * 0.025,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.titleSmall?.color,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.1),

                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Column(
                        children: [
                          Transform.translate(
                            offset: Offset(0, _verticalAnimation.value),
                            child: Opacity(
                              opacity: _opacityAnimation.value,
                              child: Text(
                                'Toca para comenzar',
                                style: TextStyle(
                                  fontSize: screenSize.height * 0.03,
                                  color: theme.textTheme.titleSmall?.color,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.015),
                          Container(
                            width: screenSize.width * 0.5,
                            height: 2,
                            color: theme.dividerColor,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
