import 'package:adrenalux_frontend_mobile/screens/game/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/screens/home/home_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/collection_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/settings_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/social/friends_screen.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CollectionScreen(),
    FriendsScreen(),
    GameScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      key: Key('menu-screen'),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label:  AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack),
            label:  AppLocalizations.of(context)!.collection,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label:  AppLocalizations.of(context)!.friends,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label:  AppLocalizations.of(context)!.games,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label:  AppLocalizations.of(context)!.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.primary, 
        unselectedItemColor: theme.colorScheme.onSurface.withAlpha(153),
        backgroundColor: theme.colorScheme.surface, 
        onTap: _onItemTapped,
      ),
    );
  }
}