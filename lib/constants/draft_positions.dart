import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/plantilla.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/constants/empty_card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';

class FieldTemplate extends StatelessWidget {
  final Draft draft;
  final bool isInteractive;
  final Function(PlayerCard?, String?)? onCardTap;

  const FieldTemplate({
    super.key,
    required this.draft,
    this.isInteractive = false,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    
    return Stack(
      alignment: Alignment.center,
      children: _buildFieldPositions(screenSize),
    );
  }

  List<Widget> _buildFieldPositions(ScreenSize screenSize) {
    return [
      _buildPosition(
        position: 'GK',
        bottom: 0.05,
        screenSize: screenSize,
      ),
      _buildPosition(
        position: 'DEF1',
        bottom: 0.225,
        left: 0.025,
        screenSize: screenSize,
      ),
      _buildPosition(
        position: 'DEF2',
        bottom: 0.225,
        left: 0.25,
        screenSize: screenSize,
      ),
      _buildPosition(
        position: 'DEF3',
        bottom: 0.225,
        left: 0.5,
        screenSize: screenSize,
      ),
      _buildPosition(
        position: 'DEF4',
        bottom: 0.225,
        left: 0.725,
        screenSize: screenSize,
      ),
      _buildPosition(
        position: 'MID1',
        bottom: 0.425,
        left: 0.1,
        screenSize: screenSize,
      ),
      _buildPosition(
        position: 'MID2',
        bottom: 0.425,
        screenSize: screenSize,
      ),
      _buildPosition(
        position: 'MID3',
        bottom: 0.425,
        left: 0.65,
        screenSize: screenSize,
      ),
      _buildPosition(
        position: 'FWD1',
        bottom: 0.6,
        left: 0.05,
        screenSize: screenSize,
      ),
      _buildPosition(
        position: 'FWD2',
        bottom: 0.65,
        screenSize: screenSize,
      ),
      _buildPosition(
        position: 'FWD3',
        bottom: 0.6,
        left: 0.7,
        screenSize: screenSize,
      ),
    ];
  }

  Widget _buildPosition({
    required String position,
    required ScreenSize screenSize,
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    final player = draft.draft[position];
    
    return Positioned(
      top: top != null ? screenSize.height * top : null,
      left: left != null ? screenSize.width * left : null,
      right: right != null ? screenSize.width * right : null,
      bottom: bottom != null ? screenSize.height * bottom : null,
      child: GestureDetector(
        key: Key('draft_card_$position'),
        onTap: isInteractive
            ? () => onCardTap?.call(player, position) 
            : null,
        child: PlayerCardWidget(
          playerCard: player ?? returnEmptyCard(),
          size: "sm",
        ),
      ),
    );
  }
}