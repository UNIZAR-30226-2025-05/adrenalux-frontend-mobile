import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/screens/home/sobre_screen.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
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

  final List<String> logros = [
    'Logro 1',
    'Logro 2',
    'Logro 3',
    'Logro 4',
    'Logro 5',
  ];

  final int monedas = 500;

  Future<void> _openPack() async {
    List<PlayerCard> cartas = await getSobre() ?? [];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OpenPackScreen(
          cartas: cartas,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = MediaQuery.of(context).size;
    final appBarHeight = screenSize.height / 13;
    final user = User();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: theme.colorScheme.surface,
          title: Stack(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Pasar a la pantalla de perfil
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Foto de perfil clicada')),
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
                      '$monedas',
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 5),
                    Image.asset('assets/moneda.png', width: 24, height: 24),
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
                      for (var i = 0; i < (logros.length > 3 ? 3 : logros.length); i++)
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
                                child: Image.asset('assets/default_profile.jpg', width: 40, height: 40, fit: BoxFit.cover),
                              ),
                              SizedBox(width: screenSize.width * 0.02),
                              Text(logros[i], style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
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
                            decoration: TextDecoration.underline,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
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
                                      Image.asset(sobres[index], fit: BoxFit.contain),
                                      SizedBox(height: 0.1),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset('assets/moneda.png', width: 20, height: 20),
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
                SizedBox(height: screenSize.height * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Panel(
                      width: screenSize.width * 0.4,
                      height: screenSize.height * 0.15,
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store, size: screenSize.width * 0.09),
                          const Text('Mercado'),
                        ],
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
