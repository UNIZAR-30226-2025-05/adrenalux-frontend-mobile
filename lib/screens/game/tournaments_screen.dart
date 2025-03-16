import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/game/play_tournament_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TournamentsScreen extends StatefulWidget {
  @override
  _TournamentsScreenState createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  List<Map<String, dynamic>> _allTournaments = [];
  List<Map<String, dynamic>> _filteredTournaments = [];
  bool _loading = true;
  bool _showGlobalTournaments = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  List<Map<String, dynamic>> _getMockTournaments() {
    return [
      {
        'id': '1',
        'name': 'Liga Premier',
        'participants': 8,
        'passwordProtected': false,
        'startDate': DateTime.now().add(Duration(days: 2)),
        'status': 'En progreso',
        'maxParticipants': 16,
        'creator': 'SoccerMaster',
      },
      {
        'id': '2',
        'name': 'Torneo Código Secreto',
        'participants': 12,
        'passwordProtected': true,
        'startDate': DateTime.now().add(Duration(days: 5)),
        'status': 'Abierto',
        'maxParticipants': 20,
        'creator': 'Admin',
        'password': 'football123',
      },
      {
        'id': '3',
        'name': 'Copa Amistosa',
        'participants': 4,
        'passwordProtected': false,
        'startDate': DateTime.now().add(Duration(days: 1)),
        'status': 'En progreso',
        'maxParticipants': 8,
        'creator': 'Amigo123',
      },
      {
        'id': '4',
        'name': 'Torneo Élite',
        'participants': 18,
        'passwordProtected': true,
        'startDate': DateTime.now().add(Duration(days: 7)),
        'status': 'Terminado',
        'maxParticipants': 20,
        'creator': 'ProPlayer',
        'password': 'champions',
      },
      {
        'id': '5',
        'name': 'Torneo Relámpago',
        'participants': 6,
        'passwordProtected': false,
        'startDate': DateTime.now().add(Duration(hours: 4)),
        'status': 'Abierto',
        'maxParticipants': 8,
        'creator': 'FastUser',
      },
    ];
  }

  Future<void> _loadTournaments() async {
    try {
      setState(() => _loading = true);
      final tournaments = _getMockTournaments(); 
      if (mounted) {
        setState(() {
          _allTournaments = tournaments;
          _filteredTournaments = tournaments;
          _loading = false;
        });
      }
    } catch (e) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: "Error al cargar los torneos",
        duration: 5,
      );
    }
  }

  Widget _buildTournamentItem(Map<String, dynamic> tournament, ThemeData theme, ScreenSize screenSize) {
    final canJoin = tournament['status'] == 'Abierto';
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.005,
        horizontal: screenSize.width * 0.02,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          Icons.emoji_events,
          color: _getStatusColor(tournament['status']),
        ),
        title: Text(tournament['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${tournament['participants']}/${tournament['maxParticipants']} participantes'),
            _buildStatusIndicator(tournament['status']),
          ],
        ),
        trailing: SizedBox(
          width: screenSize.width * 0.25,
          child: ElevatedButton(
            onPressed: canJoin ? () => _showJoinTournamentDialog(tournament) : null,
            child: Text(canJoin ? "Unirse" : "Cerrado"),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Abierto':
        return Colors.green;
      case 'En progreso':
        return Colors.orange;
      case 'Terminado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusIndicator(String status) {
    return Row(
      children: [
        Icon(Icons.circle, color: _getStatusColor(status), size: 10),
        SizedBox(width: 4),
        Text(status),
      ],
    );
  }

  void _handleCreateTournament(String name, String password) async {
    try {
      final newTournament = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'participants': 1,
        'passwordProtected': password.isNotEmpty,
        'startDate': DateTime.now().add(Duration(days: 7)),
        'status': 'Abierto',
        'maxParticipants': 16,
        'creator': 'Usuario',
        'password': password,
      };

      setState(() {
        _allTournaments = [newTournament, ..._allTournaments];
        _filteredTournaments = [newTournament, ..._filteredTournaments];
      });

      Navigator.pop(context);
      showCustomSnackBar(
        type: SnackBarType.success,
        message: "Torneo creado",
        duration: 3
      );
    } catch (e) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: e.toString(),
        duration: 5
      );
    }
  }

  Widget _buildEmptyState(String text, ThemeData theme, ScreenSize screenSize) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenSize.height * 0.025,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  void _showCreateTournamentDialog() {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final screenSize = ScreenSize.of(context);
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String? _nameError;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "Crear torneo",
          style: TextStyle(
            fontSize: screenSize.height * 0.025,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Nombre del torneo",
                  border: OutlineInputBorder(),
                  errorText: _nameError,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña (opcional)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _handleCreateTournament(
                  nameController.text, 
                  passwordController.text
                );
              }
            },
            child: Text("Crear"),
          ),
        ],
      ),
    );
  }

  void _showJoinTournamentDialog(Map<String, dynamic> tournament) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final screenSize = ScreenSize.of(context);
    final TextEditingController passwordController = TextEditingController();
    final bool hasPassword = tournament['passwordProtected'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Unirse a un torneo",
          style: TextStyle(
            fontSize: screenSize.height * 0.025,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(hasPassword)
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                  border: OutlineInputBorder(),
                ),
              ),
            if(!hasPassword)
              Text("Confirmar"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => _handleJoinTournament(
              tournament['id'], 
              passwordController.text
            ),
            child: Text("Unirse"),
          ),
        ],
      ),
    );
  }

  void _handleJoinTournament(String tournamentId, String password) async {
    try {
      //final success = await joinTournament(tournamentId, password.isNotEmpty ? password : null);
      if (true) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => TournamentScreen(
            tournament: _allTournaments.firstWhere((t) => t['id'] == tournamentId)
        )));
      }
    } catch (e) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: e.toString().replaceAll("Exception: ", ""),
        duration: 5
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    double padding = screenSize.width * 0.05;
    double avatarSize = screenSize.width * 0.3;
    double iconSize = screenSize.width * 0.07;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.surface,
          centerTitle: true,
          title: Text(
            "Torneos",
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: screenSize.height * 0.03),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/soccer_field.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Panel(
              width: screenSize.width * 0.9,
              height: screenSize.height * 0.8,
              content: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.03),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: screenSize.height * 0.6),
                      child: CustomSearchMenu<Map<String, dynamic>>(
                        items: _allTournaments,
                        getItemName: (item) => item['name'],
                        onFilteredItemsChanged: (filtered) {
                          setState(() => _filteredTournaments = filtered);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.add,
                              size: screenSize.height * 0.02,
                              color: theme.colorScheme.onPrimary),
                            label: Text(
                              "Crear",
                              style: TextStyle(
                                fontSize: screenSize.height * 0.016,
                                fontWeight: FontWeight.w500),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _showCreateTournamentDialog,
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.02),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              _showGlobalTournaments ? Icons.public : Icons.group,
                              size: screenSize.height * 0.02,
                              color: theme.colorScheme.onPrimary),
                            label: Text(
                              _showGlobalTournaments 
                                ? "Global"
                                : AppLocalizations.of(context)!.friends,
                              style: TextStyle(
                                fontSize: screenSize.height * 0.016,
                                fontWeight: FontWeight.w500),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() => _showGlobalTournaments = !_showGlobalTournaments);
                              _loadTournaments();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Expanded(
                    child: _loading
                        ? Center(child: CircularProgressIndicator())
                        : _filteredTournaments.isEmpty
                            ? _buildEmptyState(
                                "No hay torneos",
                                theme,
                                screenSize)
                            : ListView.builder(
                                itemCount: _filteredTournaments.length,
                                itemBuilder: (_, i) => _buildTournamentItem(
                                  _filteredTournaments[i],
                                  theme,
                                  screenSize),
                              ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: padding * 2,
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