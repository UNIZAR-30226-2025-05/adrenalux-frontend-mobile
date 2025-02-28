import 'package:adrenalux_frontend_mobile/screens/social/search_exchange_screen.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/screens/home/sobre_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/profile_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/market_screen.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Sobre> sobres = [];
  bool _imagesLoaded = false;
  bool _isLoadingImages = false;
  List<Sobre> _previousSobres = [];
  bool _isUserDataLoaded = false;

    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<SobresProvider>(context, listen: false).cargarSobres();
      });
      _loadInitialData();
    }

    Future<void> _loadInitialData() async {
      try {
        await getUserData(); 
        if (mounted) {
          setState(() => _isUserDataLoaded = true); 
        }
      } catch (e) {
        print('Error cargando datos iniciales: $e');
        showCustomSnackBar(
            context, SnackBarType.error, AppLocalizations.of(context)!.err_user_data, 3);
      }
    }


  Future<void> _loadImages() async {
    if (_isLoadingImages) return;
    _isLoadingImages = true;

    try {
      final imageProviders = sobres
          .map((sobre) => NetworkImage(getFullImageUrl(sobre.imagen)))
          .toList();

      await Future.wait(imageProviders.map((imageProvider) {
        return precacheImage(imageProvider, context);
      }));

      setState(() => _imagesLoaded = true);
    } catch (e) {
      setState(() => _imagesLoaded = true);
    } finally {
      _isLoadingImages = false;
    }
  }

  Future<void> _openPack() async {
    final user = User();
    if (sobres.isEmpty || _currentIndex >= sobres.length) {
      showCustomSnackBar(context, SnackBarType.error, AppLocalizations.of(context)!.err_no_packs, 5);
      return;
    }

    if (sobres[_currentIndex].precio > user.adrenacoins) {
      showCustomSnackBar(context, SnackBarType.error, AppLocalizations.of(context)!.err_money, 5);
      return;
    }

    List<PlayerCard>? cartas = await getSobre(sobres[_currentIndex].tipo, sobres[_currentIndex].precio);
    if (cartas == null) {
      showCustomSnackBar(context, SnackBarType.error, AppLocalizations.of(context)!.err_no_packs, 5);
      return;
    }

    String packImagePath = getFullImageUrl(sobres[_currentIndex].imagen);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OpenPackScreen(
          cartas: cartas,
          packImagePath: packImagePath,
        ),
      ),
    ).then((_) {
      
      setState(() {});
    });
  }

  void _navigateToMarket() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketScreen(),
      ),
    );
  }

  void _navigateToExchange() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestExchangeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUserDataLoaded) { 
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final sobresProvider = Provider.of<SobresProvider>(context);
    final screenSize = ScreenSize.of(context);
    final user = User();

    final currentSobres = sobresProvider.sobres;
    if (currentSobres != _previousSobres) {
      _previousSobres = currentSobres;
      _imagesLoaded = false;
      _isLoadingImages = false;
    }
    sobres = currentSobres;

    if (sobres.isNotEmpty && !_imagesLoaded && !_isLoadingImages) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadImages());
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
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
                    experience: user.xp,
                    xpMax: user.xpMax,
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
                    Image.asset('assets/moneda.png',
                        width: screenSize.height * 0.03,
                        height: screenSize.height * 0.03),
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
                  content: user.logros.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                            child: Text(
                              AppLocalizations.of(context)!.no_achievements,
                              style: TextStyle(
                                fontSize: screenSize.height * 0.02,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...List.generate(
                              (user.logros.length > 3 ? 3 : user.logros.length),
                              (i) => Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: screenSize.height * 0.01,
                                  horizontal: screenSize.height * 0.02,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: screenSize.height * 0.005,
                                  horizontal: screenSize.height * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Row(
                                  children: [
                                    ClipOval(
                                      child: Image.network(
                                        user.logros[i].photo,
                                        width: screenSize.height * 0.05,
                                        height: screenSize.height * 0.05,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: screenSize.width * 0.025),
                                    Text(
                                      user.logros[i].description,
                                      style: TextStyle(
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Spacer(),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: screenSize.height * 0.02),
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context)!.all_achievements),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.all_achievements,
                                    style: TextStyle(
                                      fontSize: screenSize.height * 0.015,
                                      decoration: TextDecoration.underline,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                      if (sobres.isEmpty || !_imagesLoaded)
                        Center(
                          child: CircularProgressIndicator(),
                        )
                      else
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
                                  transform: Matrix4.identity()
                                    ..scale(isCentered ? 1.0 : 0.9),
                                  child: Opacity(
                                    opacity: isCentered ? 1.0 : 0.5,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          getFullImageUrl(sobres[index].imagen),
                                          fit: BoxFit.contain,
                                          width: screenSize.height * 0.175,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return SizedBox(
                                              width: screenSize.height * 0.175,
                                              height: screenSize.height * 0.175,
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(height: screenSize.height * 0.0001),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset('assets/moneda.png',
                                                width: screenSize.height * 0.025,
                                                height: screenSize.height * 0.025),
                                            SizedBox(width: 1),
                                            Text(sobres[index].precio.toString(),
                                                style: TextStyle(
                                                    color: theme.textTheme.bodyLarge
                                                        ?.color)),
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
                              onPageChanged: (index, _) =>
                                  setState(() => _currentIndex = index),
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
                               Text(AppLocalizations.of(context)!.market),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _navigateToExchange,
                      child: Panel(
                        width: screenSize.width * 0.4,
                        height: screenSize.height * 0.15,
                        content: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.swap_horiz, size: screenSize.width * 0.09),
                             Text(AppLocalizations.of(context)!.exchange),
                          ],
                        ),
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