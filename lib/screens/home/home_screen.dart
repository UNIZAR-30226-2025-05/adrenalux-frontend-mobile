import 'dart:async';

import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:adrenalux_frontend_mobile/screens/social/search_exchange_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/achievements_screen.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
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
  late ApiService apiService;
  int _currentIndex = 0;
  List<Sobre> sobres = [];
  bool _imagesLoaded = false;
  bool _isLoadingImages = false;
  Timer? _cooldownTimer;
  bool _isProcessingClick = false;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false); 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SobresProvider>(context, listen: false).cargarSobres(context);
    });
    _loadInitialData();
    _startCooldownTimer();
  }

  void _startCooldownTimer() {
    _cooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        updateCooldown();
        setState(() {});
      }
    });
  }

  String _formatTime(int milliseconds) {
    if (milliseconds <= 0) return '00:00:00';
    
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    
    return '$hours:$minutes:$seconds';
  }

  Future<void> _loadInitialData() async {
    try {
      await apiService.getUserData(); 
      if (mounted) {
        setState(() => User().dataLoaded = true); 
        SocketService().initialize(context);
      }
    } catch (e) {
      print('Error cargando datos iniciales: $e');
      showCustomSnackBar(
          type: SnackBarType.error, 
          message: AppLocalizations.of(context)!.err_user_data, 
          duration: 3
      );
    }
  }

  Future<void> _loadImages() async {
    if (_isLoadingImages) return;
    _isLoadingImages = true;

    try {
      final imageProviders = sobres
          .map((sobre) => NetworkImage(apiService.getFullImageUrl(sobre.imagen)))
          .toList();

      await Future.wait(imageProviders.map((imageProvider) {
        return precacheImage(imageProvider, context);
      }));
      if (!mounted) return;
      setState(() => _imagesLoaded = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _imagesLoaded = true);
    } finally {
      _isLoadingImages = false;
    }
  }

  Future<void> _openPack() async {
    if (_isProcessingClick) return;
    _isProcessingClick = true;
    try {
      final user = User();
      if (sobres.isEmpty || _currentIndex >= sobres.length) {
        showCustomSnackBar(
          type: SnackBarType.error,
          message: AppLocalizations.of(context)!.err_no_packs,
          duration: 5
        );
        return;
      }

      if (sobres[_currentIndex].precio > user.adrenacoins) {
        showCustomSnackBar(
          type: SnackBarType.error,
          message: AppLocalizations.of(context)!.err_money,
          duration: 5
        );
        return;
      }

      Map<String, dynamic> response = await apiService.getSobre(sobres[_currentIndex]);
      List<PlayerCard>? cartas = response['cartas'];
      bool logroActualizado = response['logroActualizado'];

      if (cartas == null) {
        showCustomSnackBar(
          type: SnackBarType.error,
          message: AppLocalizations.of(context)!.err_no_packs,
          duration: 5
        );
        return;
      }
      subtractAdrenacoins(sobres[_currentIndex].precio);
      String packImagePath = apiService.getFullImageUrl(sobres[_currentIndex].imagen);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OpenPackScreen(
            cartas: cartas,
            packImagePath: packImagePath,
            logroActualizado: logroActualizado,
          ),
          settings: RouteSettings(name: '/open_pack'),
        ),
      ).then((_) => setState(() {}));
    } catch (e) {
      print('Error al abrir el sobre: $e');
      showCustomSnackBar(
        type: SnackBarType.error,
        message: AppLocalizations.of(context)!.err_no_packs,
        duration: 3
      );
    } finally {
      _isProcessingClick = false;
    }
  }

  Future<void> _openFreePack() async {
    if (_isProcessingClick) return;
    _isProcessingClick = true;
    try {
      final user = User();
      if (user.freePacksAvailable.value) {
        Map<String, dynamic> response = await apiService.getSobre(null);
        List<PlayerCard>? cartas = response['cartas'];
        bool logroActualizado = response['logroActualizado'];
        if (cartas == null) {
          showCustomSnackBar(
            type: SnackBarType.error,
            message: AppLocalizations.of(context)!.err_no_packs,
            duration: 5
          );
          return;
        }

        user.freePacksAvailable.value = false;
        user.lastFreePack = DateTime.now();
        updateCooldown();
        String packImagePath = apiService.getFullImageUrl(sobres[1].imagen);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OpenPackScreen(
              cartas: cartas,
              packImagePath: packImagePath,
              logroActualizado: logroActualizado,
            ),
            settings: RouteSettings(name: '/open_pack'),
          ),
        ).then((_) => setState(() {}));
      }
    } catch (e) {
      print('Error al abrir el sobre gratis: $e');
      showCustomSnackBar(
        type: SnackBarType.error,
        message: AppLocalizations.of(context)!.err_no_packs,
        duration: 3
      );
    } finally {
      _isProcessingClick = false;
    }
  }

  void _navigateToMarket() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MarketScreen()),
    );
  }

  void _navigateToExchange() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestExchangeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!User().dataLoaded) { 
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator()
        ),
      );
    }
    
    final mediaQuery = MediaQuery.of(context);
    final textScale = mediaQuery.textScaleFactor.clamp(0.8, 1.2);

    return MediaQuery(
      data: mediaQuery.copyWith(textScaleFactor: textScale),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait = constraints.maxHeight > constraints.maxWidth;

          return OrientationBuilder(
            builder: (context, orientation) {
              return Scaffold(
                appBar: _buildAppBar(constraints, isPortrait),
                body: _buildBody(constraints, isPortrait),
              );
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BoxConstraints constraints, bool isPortrait) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final user = User();

    return PreferredSize(
      preferredSize: Size.fromHeight(isPortrait 
          ? constraints.maxHeight * 0.0825
          : constraints.maxHeight * 0.14),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        title: LayoutBuilder(
          builder: (context, appBarConstraints) {
            return Stack(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
                    child: ExperienceCircleAvatar(
                      imagePath: user.photo, 
                      experience: user.xp, 
                      xpMax: user.xpMax,
                      size: isPortrait 
                          ? "sm" 
                          : "md",
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isPortrait 
                          ? constraints.maxWidth * 0.4 
                          : constraints.maxWidth * 0.3),
                    child: _buildAppBarInfo(user, theme, isPortrait)
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildAppBarInfo(User user, ThemeData theme, bool isPortrait) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${user.adrenacoins}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: isPortrait ? 14 : 12),
              ),
              SizedBox(width: 4),
              Image.asset(
                'assets/moneda.png',
                width: isPortrait ? 20 : 16,
                height: isPortrait ? 20 : 16,
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        ValueListenableBuilder<bool>(
          valueListenable: user.freePacksAvailable,
          builder: (context, freePacks, _) {
            return ValueListenableBuilder<int>(
              valueListenable: user.packCooldown,
              builder: (context, cooldown, _) {
                return FittedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (freePacks)
                        GestureDetector(
                          onTap: _openFreePack,
                          child: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.open_pack,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: isPortrait ? 12 : 10),
                              ),
                              SizedBox(width: 4),
                              Image.asset(
                                'assets/SobreComun.png',
                                width: isPortrait ? 28 : 24,
                                height: isPortrait ? 20 : 16,
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            Text(
                              _formatTime(cooldown),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: isPortrait ? 12 : 10),
                            ),
                            SizedBox(width: 4),
                            Image.asset(
                              'assets/SobreComun.png',
                              width: isPortrait ? 28 : 24,
                              height: isPortrait ? 20 : 16,
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BoxConstraints constraints, bool isPortrait) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/soccer_field.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          bottom: 20,
          left: isPortrait ? 16 : 24,
          right: isPortrait ? 16 : 24,
        ),
        child: Consumer<SobresProvider>(
          builder: (context, sobresProvider, _) {
            sobres = sobresProvider.sobres;
            if (sobres.isNotEmpty && !_imagesLoaded && !_isLoadingImages) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _loadImages());
            }

            return Column(
              children: [
                _buildAchievementsPanel(constraints, isPortrait),
                SizedBox(height: isPortrait ? 16 : 24),
                Expanded(child: _buildPacksCarousel(constraints, isPortrait)),
                SizedBox(height: isPortrait ? 16 : 24),
                _buildActionButtons(constraints, isPortrait),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAchievementsPanel(BoxConstraints constraints, bool isPortrait) {
    final user = User();
    return Panel(
      width: double.infinity,
      height: isPortrait 
          ? constraints.maxHeight * 0.25 
          : constraints.maxHeight * 0.18,
      content: user.logros.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.no_achievements))
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: user.logros.length > 3 ? 3 : user.logros.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => 
                        _buildAchievementItem(user.logros[index]),
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AchievementsScreen()),
                    ),
                    child: Text(AppLocalizations.of(context)!.all_achievements),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAchievementItem(Logro logro) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return ListTile(
      leading: Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
      title: Text(
        logro.description,
        style: theme.textTheme.bodyMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      minLeadingWidth: 32,
      dense: true,
    );
  }

  Widget _buildPacksCarousel(BoxConstraints constraints, bool isPortrait) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1000;
    final isDesktop = screenWidth >= 1000;

    return Panel(
      width: double.infinity,
      height: double.infinity,
      content: sobres.isEmpty || !_imagesLoaded
          ? Center(child: CircularProgressIndicator())
          : CarouselSlider.builder(
              itemCount: sobres.length,
              itemBuilder: (context, index, _) {
                final isCentered = index == _currentIndex;
                return GestureDetector(
                  onTap: _openPack,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeOutQuad,
                    margin: EdgeInsets.symmetric(
                      horizontal: isMobile ? 4 : 6,
                      vertical: 4,
                    ),
                    transform: Matrix4.identity()
                      ..scale(isCentered ? 0.95 : 0.8),
                    child: Opacity(
                      opacity: isCentered ? 1.0 : 0.8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              width: _getCardWidth(screenWidth, isMobile, isTablet, isDesktop),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  apiService.getFullImageUrl(sobres[index].imagen),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        value: progress.expectedTotalBytes != null
                                            ? progress.cumulativeBytesLoaded /
                                                progress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 6, bottom: 4),
                            child: FittedBox(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/moneda.png',
                                      width: 16,
                                      height: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      sobres[index].precio.toString(),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: isMobile 
                    ? constraints.maxHeight * 0.35 
                    : constraints.maxHeight * 0.45,
                aspectRatio: 1.3,
                viewportFraction: _getViewportFraction(isMobile, isTablet, isDesktop),
                enableInfiniteScroll: true,
                enlargeCenterPage: true,
                enlargeFactor: 0.2,
                enlargeStrategy: CenterPageEnlargeStrategy.scale,
                onPageChanged: (index, _) => setState(() => _currentIndex = index),
              ),
            ),
    );
  }

  double _getCardWidth(double screenWidth, bool isMobile, bool isTablet, bool isDesktop) {
    if (isDesktop) return screenWidth * 0.18;
    if (isTablet) return screenWidth * 0.28;
    return isMobile ? screenWidth * 0.4 : screenWidth * 0.25;
  }

  double _getViewportFraction(bool isMobile, bool isTablet, bool isDesktop) {
    if (isDesktop) return 0.45;
    if (isTablet) return 0.55;
    return isMobile ? 0.5 : 0.35;
  }

  Widget _buildActionButtons(BoxConstraints constraints, bool isPortrait) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: isPortrait ? 40 : 55,
      runSpacing: 16,
      children: [
        _buildActionButton(
          icon: Icons.store,
          label: AppLocalizations.of(context)!.market,
          onTap: _navigateToMarket,
          isPortrait: isPortrait,
          constraints: constraints,
        ),
        _buildActionButton(
          icon: Icons.swap_horiz,
          label: AppLocalizations.of(context)!.exchange,
          onTap: _navigateToExchange,
          isPortrait: isPortrait,
          constraints: constraints,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPortrait,
    required BoxConstraints constraints,
  }) {
    final size = isPortrait 
        ? constraints.maxWidth * 0.4 
        : constraints.maxWidth * 0.3;

    return GestureDetector(
      onTap: onTap,
      child: Panel(
        width: size,
        height: size * 0.8,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: size * 0.25),
            SizedBox(height: 8),
            FittedBox(
              child: Text(
                label,
                style: TextStyle(fontSize: size * 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}