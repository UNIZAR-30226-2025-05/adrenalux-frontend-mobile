import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/screens/home/sobre_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/profile_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/market_screen.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> sobres = [
    'assets/SobreComun.png',
    'assets/SobreRaro.png',
    'assets/SobreEpico.png',
  ];

  final List<String> precios = [
    '50',
    '100',
    '200',
  ];

  Future<void> _openPack() async {
    List<PlayerCard> cartas = await getSobre() ?? [];
    String packImagePath = sobres[_currentIndex];

     Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 100),
        pageBuilder: (_, animation, secondaryAnimation) => OpenPackScreen(
          cartas: cartas,
          packImagePath: packImagePath, // Añadir este parámetro
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              FadeTransition(
                opacity: Tween(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.5, 1.0),
                  ),
                ),
              ),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
              ),
              ScaleTransition(
                scale: animation,
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToMarket() {
    Navigator.push(
      context, MaterialPageRoute(
        builder: (context) => MarketScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);
    final user = User();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false, // Quitar el botón de ir hacia atrás
          backgroundColor: theme.colorScheme.surface,
          title: Stack(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(),
                      ),
                    );
                  },
                  child: ExperienceCircleAvatar(
                    imagePath: user.photo,
                    experience: user.xp.toDouble(),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: Row(
                  children: [
                    Text(
                      '${user.adrenacoins}',
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: screenSize.height * 0.02,
                      ),
                    ),
                    SizedBox(width: 5),
                    Image.asset('assets/moneda.png', width: screenSize.height * 0.03, height: screenSize.height * 0.03),
                  ],
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/soccer_field.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenSize.height * 0.01),
                Panel(
                  width: screenSize.width * 0.85,
                  height: screenSize.height * 0.25,
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (user.logros.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                          child: Text(
                            'Aún no has conseguido ningún logro',
                            style: TextStyle(
                              fontSize: screenSize.height * 0.02,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else ...[
                        for (var i = 0; i < (user.logros.length > 3 ? 3 : user.logros.length); i++)
                          Container(
                            margin: EdgeInsets.fromLTRB(screenSize.height * 0.02, screenSize.height * 0.005, screenSize.height * 0.02, screenSize.height * 0.005),
                            padding: EdgeInsets.fromLTRB(screenSize.height * 0.01, screenSize.height * 0.005, screenSize.height * 0.01, screenSize.height * 0.005),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: Image.asset(user.logros[i].photo, width: screenSize.height * 0.05, height: screenSize.height * 0.05, fit: BoxFit.cover),
                                ),
                                SizedBox(width: screenSize.width * 0.015),
                                Text(user.logros[i].name, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                              ],
                            ),
                          ),
                        SizedBox(height: screenSize.height * 0.01),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ver todos los logros')),
                            );
                          },
                          child: Text(
                            'Ver todos los logros',
                            style: TextStyle(
                              fontSize: screenSize.height * 0.015,
                              decoration: TextDecoration.underline,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Panel(
                  width: screenSize.width * 0.85,
                  height: screenSize.height * 0.35,
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: CarouselSlider.builder(
                          itemCount: sobres.length,
                          itemBuilder: (context, index, _) {
                            final isCentered = index == _currentIndex;
                            return GestureDetector(
                              onTap: _openPack,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                transform: Matrix4.identity()..scale(isCentered ? 1.0 : 0.9),
                                child: Opacity(
                                  opacity: isCentered ? 1.0 : 0.5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(sobres[index], fit: BoxFit.contain, width: screenSize.height * 0.175),
                                      SizedBox(height: screenSize.height * 0.0001),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset('assets/moneda.png', width: screenSize.height * 0.025, height: screenSize.height * 0.025),
                                          SizedBox(width: 1),
                                          Text(precios[index], style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          options: CarouselOptions(
                            aspectRatio: 2,
                            height: screenSize.height * 0.4,
                            viewportFraction: 0.45,
                            enableInfiniteScroll: true,
                            enlargeCenterPage: true,
                            onPageChanged: (index, _) => setState(() => _currentIndex = index),
                            scrollPhysics: ClampingScrollPhysics(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _navigateToMarket,
                      child: Panel(
                        width: screenSize.width * 0.4,
                        height: screenSize.height * 0.15,
                        content: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store, size: screenSize.width * 0.09),
                              const Text('Mercado'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Panel(
                      width: screenSize.width * 0.4,
                      height: screenSize.height * 0.15,
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swap_horiz, size: screenSize.width * 0.09),
                          const Text('Intercambio'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.01),
              ],
            ),
          ),
        ],
      ),
    );
  }
}