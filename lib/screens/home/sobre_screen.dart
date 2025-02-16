import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'dart:math';

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

    await Future.delayed(800.ms);

    if (_currentCardIndex >= widget.cartas.length - 1) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _currentCardIndex++;
      _isAnimating = false;
      _showExitAnimation = false;
    });
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
      child: SizedBox(
        width: screenSize.width * 0.5,
        child: Image.asset(widget.packImagePath),
      )
      .animate(target: _isPackAnimating ? 1 : 0)
      .shimmer(
        delay: 300.ms,
        duration: 1500.ms,
        angle: -0.5,
        color: Colors.white.withOpacity(0.6),
      )
      .moveY(begin: 0, end: -10, duration: 2000.ms, curve: Curves.easeInOut)
      .then()
      .moveY(begin: -10, end: 0, duration: 2000.ms, curve: Curves.easeInOut)
      .then(delay: 100.ms)
      .scaleXY(
        begin: 1,
        end: 1.8,
        curve: Curves.easeOutBack,
        duration: 300.ms,
      )
      .shake(
        hz: 4,
        offset: const Offset(0.4, 0.0),
        duration: 300.ms,
      )
      .then()
      .rotate(
        begin: 0,
        end: 2 * pi,
        duration: 800.ms,
        curve: Curves.easeInOutCubic,
      )
      .scaleXY(
        begin: 1.8,
        end: 0.3,
        duration: 800.ms,
      )
      .fade(begin: 1, end: 0.3, duration: 400.ms)
      .fadeOut(duration: 600.ms),
    );
  }

  Widget _buildNextCardPreview() {
    return Center(
      child: PlayerCardWidget(
        playerCard: widget.cartas[_currentCardIndex + 1],
        size: "lg",
      ).animate(onPlay: (controller) => controller.repeat())
          .moveY(begin: 0, end: -15, duration: 2000.ms, curve: Curves.easeInOut)
          .then()
          .moveY(begin: -15, end: 0, duration: 2000.ms, curve: Curves.easeInOut),
    );
  }

  Widget _buildCardWithFloatingAnimation() {
    return Center(
      child: PlayerCardWidget(
        playerCard: widget.cartas[_currentCardIndex],
        size: "lg",
      ).animate(onPlay: (controller) => controller.repeat())
          .moveY(begin: 0, end: -15, duration: 2000.ms, curve: Curves.easeInOut)
          .then()
          .moveY(begin: -15, end: 0, duration: 2000.ms, curve: Curves.easeInOut),
    );
  }

  Widget _buildExitAnimation() {
    return Center(
      child: PlayerCardWidget(
        playerCard: widget.cartas[_currentCardIndex],
        size: "lg",
      ).animate()
          .slideX(begin: 0, end: 2.0, curve: Curves.easeIn)
          .rotate(begin: 0, end: 0.15, curve: Curves.easeIn)
          .fadeOut(duration: 500.ms),
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
              experience: user.xp.toDouble(),
            ),
          ),
          Positioned(
            right: 0,
            child: Row(
              children: [
                Text('${user.adrenacoins}',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: screenSize.height * 0.02,
                  ),
                ),
                const SizedBox(width: 5),
                Image.asset('assets/moneda.png', 
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