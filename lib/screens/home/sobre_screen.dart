import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';

class OpenPackScreen extends StatefulWidget {
  final List<PlayerCard> cartas;

  OpenPackScreen({required this.cartas});

  @override
  _OpenPackScreenState createState() => _OpenPackScreenState();
}

class _OpenPackScreenState extends State<OpenPackScreen> {
  int _currentCardIndex = 0;
  bool _isAnimating = false;
  bool _showExitAnimation = false;

  Future<void> _showNextCard() async {
    if (_isAnimating || _currentCardIndex >= widget.cartas.length) return;

    setState(() {
      _isAnimating = true;
      _showExitAnimation = true;
    });

    await Future.delayed(Duration(milliseconds: 800));

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
    final screenSize = MediaQuery.of(context).size;
    final appBarHeight = screenSize.height / 13;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: _buildAppBar(theme),
      ),
      body: AbsorbPointer(
        absorbing: _isAnimating,
        child: GestureDetector(
          onTap: _showNextCard,
          onHorizontalDragEnd: (details) => _showNextCard(),
          child: Stack(
            children: [
              _buildBackground(),
              if (_showExitAnimation && _currentCardIndex < widget.cartas.length - 1)
                _buildNextCardPreview(),
              if (!_showExitAnimation) _buildCardWithFloatingAnimation(),
              if (_showExitAnimation) _buildExitAnimation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextCardPreview() {
    return Center(
      child: widget.cartas[_currentCardIndex + 1]
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .moveY(
            begin: 0,
            end: -15,
            duration: 2000.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .moveY(
            begin: -15,
            end: 0,
            duration: 2000.ms,
            curve: Curves.easeInOut,
          )
    );
  }

  Widget _buildCardWithFloatingAnimation() {
    return Center(
      child: widget.cartas[_currentCardIndex]
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .moveY(
            begin: 0,
            end: -15,
            duration: 2000.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .moveY(
            begin: -15,
            end: 0,
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
    );
  }

  Widget _buildExitAnimation() {
    return Center(
      child: widget.cartas[_currentCardIndex]
          .animate()
          .slideX(
            begin: 0,
            end: 2.0,
            curve: Curves.easeIn,
          )
          .rotate(
            begin: 0,
            end: 0.15,
            curve: Curves.easeIn,
          )
          .fadeOut(),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.surface,
      title: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: () {},
              child: ExperienceCircleAvatar(
                imagePath: 'assets/default_profile.jpg',
                experience: 0.1,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Row(
              children: [
                Text(
                  '500',
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