import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FocusCardScreen extends StatelessWidget {
  final PlayerCard playerCard;

  const FocusCardScreen({
    required this.playerCard,
    Key? key,
  }) : super(key: key);

  void _sellCard(context) {
    showCustomSnackBar(
      context,
      SnackBarType.success,
      AppLocalizations.of(context)!.card_on_sale, 3,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(screenSize.width *0.05, 0, 0, 0),
                  child: PlayerCardWidget(playerCard: playerCard, size: "lg"),),
                
                SizedBox(height: screenSize.height * 0.0005),
                GestureDetector(
                  onTap: () => _sellCard(context),
                  child: Container(
                    width: screenSize.width * 0.8,
                    padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.015),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.onPrimaryFixedVariant,
                          theme.colorScheme.onPrimaryFixed
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: screenSize.width * 0.05),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/moneda.png',
                                width: screenSize.height * 0.03,
                                height: screenSize.height * 0.03,
                              ),
                              SizedBox(width: screenSize.width * 0.02),
                              Text(
                                '${playerCard.price}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenSize.height * 0.025,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: screenSize.width * 0.05),
                          child: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.sell,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenSize.height * 0.025,
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.02),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}