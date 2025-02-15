import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/screens/home/home_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/collection_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CollectionScreen(),
    Text('Amigos'),
    Text('Partidas'),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack),
            label: 'Colección',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Amigos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Partidas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
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