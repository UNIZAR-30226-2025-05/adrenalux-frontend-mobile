import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _isOnSale = widget.playerCard.onSale;
  }

  void _confirmSell() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirm_sale_title),
          content: Text(AppLocalizations.of(context)!.confirm_sale_message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isOnSale = true;
                  widget.playerCard.onSale = true; 
                });
                Navigator.of(context).pop();
                showCustomSnackBar(
                  type: SnackBarType.success,
                  message: AppLocalizations.of(context)!.card_on_sale,
                  duration: 3,
                );
              },
              child: Text(AppLocalizations.of(context)!.accept),
            ),
          ],
        );
      },
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
                    child: PlayerCardWidget(
                      playerCard: widget.playerCard,
                      size: "md",
                    ),
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
                    onTap: _isOnSale ? null : () => _confirmSell(),
                    child: Container(
                      width: screenSize.width * 0.8,
                      padding: EdgeInsets.symmetric(
                          vertical: screenSize.height * 0.015),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenSize.width * 0.05),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/moneda.png',
                                        width: screenSize.height * 0.03,
                                        height: screenSize.height * 0.03,
                                      ),
                                      SizedBox(
                                          width: screenSize.width * 0.02),
                                      Text(
                                        '${widget.playerCard.price}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              screenSize.height * 0.025,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: screenSize.width * 0.05),
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
