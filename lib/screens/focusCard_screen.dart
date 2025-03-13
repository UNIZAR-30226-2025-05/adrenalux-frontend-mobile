import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math' as math;

class FocusCardScreen extends StatefulWidget {
  final PlayerCard playerCard;

  const FocusCardScreen({
    required this.playerCard,
    Key? key,
  }) : super(key: key);

  @override
  _FocusCardScreenState createState() => _FocusCardScreenState();
}

class _FocusCardScreenState extends State<FocusCardScreen> {
  late bool _isOnSale;
  final TextEditingController _priceController = TextEditingController();
  double _rotation = 0.0;
  final double _perspective = 0.002;

  @override
  void initState() {
    super.initState();
    _isOnSale = widget.playerCard.onSale;
  }

  @override
  void dispose() {
    _priceController.dispose(); 
    super.dispose();
  }

  void _sellCard(int cartaId, double precio) async {
    if (precio <= 0) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: AppLocalizations.of(context)!.invalid_price,
        duration: 3,
      );
      return;
    }
    final success = await sellCard(cartaId, precio);

    if(success) {
      showCustomSnackBar(
        type: SnackBarType.success,
        message: AppLocalizations.of(context)!.card_on_sale,
        duration: 3,
      );
      setState(() {
        _isOnSale = true;
        widget.playerCard.onSale = true; 
      });
    } else {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: AppLocalizations.of(context)!.card_on_sale,
        duration: 3,
      );
    }
  }

  void _confirmSell(int cartaId) { 
    showDialog(
      context: context,
      builder: (context) {
        final theme = Provider.of<ThemeProvider>(context).currentTheme;
        final screenSize = ScreenSize.of(context);
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.set_sale_price),
              content: SizedBox(
                height: screenSize.height * 0.15,
                child: Column(
                  children: [
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.price,
                        prefixIcon: Image.asset(
                          'assets/moneda.png',
                          width: screenSize.height * 0.025,
                          height: screenSize.height * 0.025,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    if(_priceController.text.isNotEmpty)
                      Text(
                        '${AppLocalizations.of(context)!.sell_for} ${_priceController.text}',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: screenSize.height * 0.018,
                        ),
                      ),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final price = double.tryParse(_priceController.text);
                    if (price == null || price <= 0) {
                      showCustomSnackBar(
                        type: SnackBarType.error,
                        message: AppLocalizations.of(context)!.invalid_price,
                        duration: 3);
                      return;
                    }
                    _sellCard(cartaId, price);
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteFromMarket(int? cartaId) async {
    final success = await deleteFromMarket(cartaId);

    if(success) {
      showCustomSnackBar(
        type: SnackBarType.success,
        message: AppLocalizations.of(context)!.card_removed_from_market,
        duration: 3,
      );
      setState(() {
        _isOnSale = false;
        widget.playerCard.onSale = false; 
      });
    } else {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: AppLocalizations.of(context)!.failed_to_remove_card,
        duration: 3,
      );
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final double sensitivity = 0.015; 

    setState(() {
      _rotation -= details.delta.dx * sensitivity;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final double twoPi = 2 * math.pi;
    final double effectiveRotation = _rotation % twoPi;
    
    if (effectiveRotation < 1 || effectiveRotation > twoPi - 1) {
      setState(() {
        _rotation = _rotation - effectiveRotation;
      });
    } else if ((effectiveRotation - math.pi).abs() < 1) {
      setState(() {
        _rotation = _rotation - effectiveRotation + math.pi;
      });
    }
  }

  Widget _buildCard(ScreenSize screenSize) {
    final cardSize = PlayerCardWidget.getCardSize("md", screenSize.width);
    final double effectiveRotation = _rotation.abs() % (2 * math.pi);
    final bool showBack = effectiveRotation > math.pi / 2 && effectiveRotation < 3 * math.pi / 2;

    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, _perspective)
          ..rotateY(_rotation),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showBack)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: Container(
                width: cardSize.width,
                height: cardSize.height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      tiposCarta[widget.playerCard.rareza] ?? 'assets/card_template.png',
                      fit: BoxFit.cover,
                    ),

                    Positioned(
                      bottom: screenSize.height * 0.16,
                      left: screenSize.width * 0.125, 
                      right: 0,
                      child: Container(
                        width: cardSize.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start, 
                          children: List.generate(
                            4, 
                            (index) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: cardSize.width * 0.015),
                              child: Icon(
                                Icons.star_rounded,
                                color: index < (ordenRareza[widget.playerCard.rareza]! + 1) 
                                    ? Color(0xFFD4AF37)
                                    : Colors.black, 
                                size: cardSize.height * 0.075,
                                shadows: [
                                  BoxShadow(
                                    color: const Color.fromARGB(28, 145, 145, 145).withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: cardSize.height * 0.175,
                      child: Container(
                        width: cardSize.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'POSICIÓN',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: cardSize.height * 0.04,  
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                SizedBox(height: cardSize.height * 0.01),
                                Container(
                                  alignment: Alignment.center, 
                                  constraints: BoxConstraints(
                                    minWidth: cardSize.width * 0.4, 
                                    maxWidth: cardSize.width * 0.6,  
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: cardSize.width * 0.03, 
                                    vertical: cardSize.height * 0.01,   
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(cardSize.height * 0.03),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.playerCard.position.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: cardSize.height * 0.045, 
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Image.asset(
                      tiposCarta[widget.playerCard.rareza] ?? 'assets/card_template.png',
                      fit: BoxFit.cover,
                      color: const Color.fromARGB(114, 147, 147, 147).withOpacity(0.2),
                    ),
                  ],
                ),
              ),
            ),
            if (!showBack)
              PlayerCardWidget(
                playerCard: widget.playerCard,
                size: "md",
              ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    double padding = screenSize.width * 0.05;
    double avatarSize = screenSize.width * 0.3;
    double iconSize = screenSize.width * 0.07;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.surface,
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.collection,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: screenSize.height * 0.03,
              ),
            ),
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
          Center(
            child: Padding(
              padding: EdgeInsets.all(screenSize.width * 0.05),
              child: Panel(
                width: screenSize.width * 0.9,
                height: screenSize.height * 0.8,
                content: Container(),
              ),
            ),
          ),
          Positioned(
            right: screenSize.width *0.125,
            top: screenSize.height * 0.06,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width  * 0.025,vertical:  screenSize.width  * 0.005),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '${widget.playerCard.amount}',
                style: TextStyle(
                  fontSize: screenSize.height * 0.025,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(screenSize.width * 0.05, 0, 0, 0),
                    child: _buildCard(screenSize),
                  ),
                  Container(
                    width: screenSize.width * 0.8,
                    child: Divider(
                      color: Colors.grey.shade400,
                      thickness: 1.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: screenSize.width * 0.75,
                        padding: EdgeInsets.all(screenSize.width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.playerCard.playerName}',
                              style: TextStyle(
                                fontSize: screenSize.height * 0.03,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            Text(
                              AppLocalizations.of(context)!.team + ': ${widget.playerCard.team}',
                              style: TextStyle(
                                fontSize: screenSize.height * 0.02,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              'Rareza: ${widget.playerCard.rareza}',
                              style: TextStyle(
                                fontSize: screenSize.height * 0.02,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.position +': ${widget.playerCard.position}',
                              style: TextStyle(
                                fontSize: screenSize.height * 0.02,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.005),

                  GestureDetector(
                    onTap: _isOnSale ? () =>  _deleteFromMarket(widget.playerCard.id) : 
                                       () => _confirmSell(widget.playerCard.id),
                    child: Container(
                      width: screenSize.width * 0.8,
                      padding: EdgeInsets.symmetric(
                        vertical: screenSize.height * 0.015
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isOnSale
                              ? [
                                  theme.colorScheme.errorContainer, 
                                  theme.colorScheme.errorContainer,
                                ]
                              : [
                                  theme.colorScheme.onPrimaryFixedVariant,
                                  theme.colorScheme.onPrimaryFixed,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: _isOnSale
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.on_sale,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenSize.height * 0.025,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenSize.width * 0.05),
                                  child: Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.sell,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              screenSize.height * 0.025,
                                        ),
                                      ),
                                      SizedBox(
                                          width: screenSize.width * 0.02),
                                      Icon(
                                        Icons.sell,
                                        color: Colors.white,
                                        size: screenSize.height * 0.03,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: padding * 0.5,
            left: padding * 2,
            right: padding * 2,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: avatarSize * 0.6,
                height: avatarSize * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryFixedDim,
                      theme.colorScheme.primaryFixed,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.onPrimaryFixed,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.surfaceBright,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: theme.colorScheme.onInverseSurface,
                    size: iconSize * 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}