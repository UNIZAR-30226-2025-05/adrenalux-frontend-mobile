import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/animations/pack_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OpenPackScreen extends StatefulWidget {
  final List<PlayerCard> cartas;
  final String packImagePath;

  const OpenPackScreen({
    Key? key,
    required this.cartas,
    required this.packImagePath,
  }) : super(key: key);

  @override
  _OpenPackScreenState createState() => _OpenPackScreenState();
}

class _OpenPackScreenState extends State<OpenPackScreen> {
  int _currentCardIndex = 0;
  bool _isAnimating = false;
  bool _showExitAnimation = false;
  bool _showPack = true;
  bool _isPackAnimating = false;
  bool _allImagesLoaded = false;
  bool _isMegaLuxuryAnimationActive = false;

  late List<PlayerCardWidget> preloadedCardWidgets;

  @override
  void initState() {
    super.initState();
    preloadedCardWidgets = widget.cartas.map((card) => PlayerCardWidget(
      key: ValueKey(card.hashCode),
      playerCard: card,
      size: "lg",
      playerPhotoImage: NetworkImage(card.playerPhoto),
      teamLogoImage: card.teamLogo.isNotEmpty ? NetworkImage(card.teamLogo) : null,
    )).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
    });
  }

  Future<void> _preloadImages() async {
    List<Future> precacheFutures = [];

    precacheFutures.add(precacheImage(NetworkImage(widget.packImagePath), context));

    for (var card in widget.cartas) {
      precacheFutures.add(precacheImage(NetworkImage(card.playerPhoto), context));
      if (card.teamLogo.isNotEmpty) {
        precacheFutures.add(precacheImage(NetworkImage(card.teamLogo), context));
      }
    }
    await Future.wait(precacheFutures);

    setState(() {
      _allImagesLoaded = true;
    });
  }

  Future<void> _handlePackAnimation() async {
    if (_isPackAnimating) return;
    
    setState(() => _isPackAnimating = true);
    
    await Future.delayed(1200.ms);
    
    setState(() {
      _showPack = false;
      _isPackAnimating = false;
    });
  }

  Future<void> _showNextCard() async {
    if (_isAnimating || _currentCardIndex >= widget.cartas.length) return;
    setState(() {
      _isAnimating = true;
      _showExitAnimation = true;
    });

    await Future.delayed(400.ms);

    if (_currentCardIndex >= widget.cartas.length - 1) {
      _showSummaryDialog();
      return;
    }

    setState(() {
      _currentCardIndex++;
      _isAnimating = false;
      _showExitAnimation = false;
    });
  }

  void _showSummaryDialog() {
    final screenSize = ScreenSize.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(screenSize.height * 0.01),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.035),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.new_cards,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.025),
              SizedBox(
                width: screenSize.width * 0.9,
                height: screenSize.height * 0.4,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.cartas.take(3).map((card) => 
                          PlayerCardWidget(
                            playerCard: card,
                            size: 'sm',
                            playerPhotoImage: NetworkImage(card.playerPhoto),
                            teamLogoImage: card.teamLogo.isNotEmpty 
                                ? NetworkImage(card.teamLogo) 
                                : null,
                          ),
                        ).toList(),
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: widget.cartas.skip(3).take(3).map((card) => SizedBox(
                          child: PlayerCardWidget(
                            playerCard: card,
                            size: 'sm',
                            playerPhotoImage: NetworkImage(card.playerPhoto),
                            teamLogoImage: card.teamLogo.isNotEmpty 
                                ? NetworkImage(card.teamLogo) 
                                : null,
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.075, vertical: screenSize.height * 0.02),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); 
                },
                child: Text(
                  AppLocalizations.of(context)!.return_msg,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: screenSize.height * 0.015,
                  ),
                ),
              ),
            ],
          ),
        ),
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
        child: _buildAppBar(theme, user, screenSize),
      ),
      body: AbsorbPointer(
        absorbing: _isAnimating || _isPackAnimating,
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (_isMegaLuxuryAnimationActive) return;
            
            if (!_isPackAnimating && _showPack) {
              _handlePackAnimation();
            } else if (!_isAnimating) {
              _showNextCard();
            }
          },
          child: Stack(
            children: [
              _buildBackground(),
              if (_showPack) _buildPackAnimation(screenSize),
              if (!_showPack) ...[
                if (_showExitAnimation && _currentCardIndex < widget.cartas.length - 1)
                  _buildNextCardPreview(),
                if (!_showExitAnimation) _buildCardWithFloatingAnimation(),
                if (_showExitAnimation) _buildExitAnimation(),
              ].whereType<Widget>().toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackAnimation(ScreenSize screenSize) {
    return Center(
      child: PackAnimations.packOpeningAnimation(
        SizedBox(
          width: screenSize.width * 0.5,
          child: Image.network(widget.packImagePath),
        ),
        _isPackAnimating,
      ),
    );
  }

  Widget _buildNextCardPreview() {
    if (widget.cartas[_currentCardIndex + 1].rareza != CARTA_LUXURYXI &&
        widget.cartas[_currentCardIndex + 1].rareza != CARTA_MEGALUXURY &&
        widget.cartas[_currentCardIndex].rareza != CARTA_LUXURYXI &&
        widget.cartas[_currentCardIndex].rareza != CARTA_MEGALUXURY) {
      return Center(
        child: PackAnimations.cardFloatAnimation(
          preloadedCardWidgets[_currentCardIndex + 1],
        ),
      );
    }
    return Center();
  }

  Widget _buildCardWithFloatingAnimation() {
    final currentCard = widget.cartas[_currentCardIndex];
    final isSpecialCard = currentCard.rareza == CARTA_LUXURYXI || currentCard.rareza == CARTA_MEGALUXURY;
    
    if (isSpecialCard) {
      _isMegaLuxuryAnimationActive = true;
      Future.delayed(const Duration(seconds: 5), () => _isMegaLuxuryAnimationActive = false);
    }

    return Stack(
      children: [
        if (!_allImagesLoaded)
          Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        Center(
          child: isSpecialCard
              ? PackAnimations.megaLuxurySpecialAnimation(
                  child: preloadedCardWidgets[_currentCardIndex],
                  teamLogo: currentCard.teamLogo,
                  position: currentCard.position,
                  context: context,
                  onAnimationStart: () => _isMegaLuxuryAnimationActive = true,
                  onAnimationEnd: () => _isMegaLuxuryAnimationActive = false,
                )
                .animate()
                .fadeIn(duration: 50.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 300.ms)
              : PackAnimations.cardFloatAnimation(
                  preloadedCardWidgets[_currentCardIndex],
                ),
        ),
      ],
    );
  }

  Widget _buildExitAnimation() {
    return Center(
      child: PackAnimations.cardExitAnimation(
        preloadedCardWidgets[_currentCardIndex],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, User user, ScreenSize screenSize) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.surface,
      title: Stack(
        children: [
          Center(
            child: ExperienceCircleAvatar(
              imagePath: user.photo,
              experience: user.xp,
              xpMax: user.xpMax,
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
                const SizedBox(width: 5),
                Image.asset(
                  'assets/moneda.png',
                  width: screenSize.height * 0.03,
                  height: screenSize.height * 0.03,
                ),
              ],
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/soccer_field.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
