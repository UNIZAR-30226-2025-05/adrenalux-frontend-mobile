import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/close_button_widget.dart';
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
  static const int MAX_PARTICIPANTES = 8;
  List<Map<String, dynamic>> _allTournaments = [];
  List<Map<String, dynamic>> _filteredTournaments = [];
  ApiService apiService = ApiService();
  bool _loading = true;
  bool _showGlobalTournaments = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    try {
      setState(() => _loading = true);

      final userTournaments = (await apiService.getUserTournaments())
          .map((t) => _formatTournament(t))
          .toList();

      final ongoingTournament = userTournaments.isNotEmpty
          ? userTournaments.firstWhere(
          (t) => t['ganador_id'] == null,
          orElse: () => {},
        )
          : {};

      if (ongoingTournament.isNotEmpty) {
        setUserTournamentId(ongoingTournament['id']);
        _redirectToUserTournament();
        return;
      }
      final List<dynamic> tournaments = _showGlobalTournaments 
        ? await apiService.getActiveTournaments()
        : await apiService.getFriendsTournaments();
      
      if (mounted) {
        setState(() {
          _allTournaments = tournaments.map((t) => _formatTournament(t)).toList();
          _filteredTournaments = List.from(_allTournaments);
          _loading = false;
        });
      }
    } catch (e) {
      if (e.toString().contains('404')) { 
        setState(() {
          _allTournaments = [];
          _filteredTournaments = [];
          _loading = false;
        });
      } else {
        showCustomSnackBar(
          type: SnackBarType.error,
          message: "Error al cargar torneos: ${e.toString()}",
          duration: 5,
        );
      }
    }
  }

  Future<void> _redirectToUserTournament() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final currentUser = User();
      
      final details = await api.getTournamentDetails(currentUser.torneo_id.toString());
      
      final List<dynamic> participantesData = details['participantes'];
      final List<Map<String, dynamic>> fullParticipants = [];
      
      await Future.wait(participantesData.map((basicData) async {
        try {
          final fullData = await api.getFriendDetails(basicData['user_id'].toString());
          final victorias = fullData['partidas']
              .where((p) => p.winnerId == fullData['id'])
              .length;
              
          final progreso = fullData['xp'] / fullData['xpMax'];
          
          fullParticipants.add({
            'id': fullData['id'],
            'nombre': fullData['name'],
            'avatar': fullData['avatar'],
            'level': fullData['level'],
            'xp': fullData['xp'],
            'xpMax': fullData['xpMax'],
            'victorias': victorias,
            'partidas': fullData['partidas'],
            'progreso': progreso,
            'isOnline': fullData['isOnline'] ?? false,
            'isCurrentUser': fullData['id'] == currentUser.id,
            'logros': fullData['logros'],
          });
        } catch (e) {
          print('Error cargando participante: ${e.toString()}');
        }
      }));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TournamentScreen(
              tournament: _formatTournament(details['torneo']),
              participants: fullParticipants,
            ),
          ),
        );
      }
    } catch (e) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: "Error al acceder al torneo: ${e.toString().replaceAll("Exception: ", "")}",
        duration: 5,
      );
    }
  }

  Map<String, dynamic> _formatTournament(Map<String, dynamic> apiData) {
    return {
      'id': apiData['id'].toString(),
      'name': apiData['nombre'],
      'description' : apiData['descripcion'],
      'prize' : apiData['premio'],
      'passwordProtected': apiData['contrasena'] != null,
      'startDate': apiData['fecha_inicio'] != null 
          ? DateTime.parse(apiData['fecha_inicio']) 
          : null,
      'status': _getStatus(apiData),
      'maxParticipants': MAX_PARTICIPANTES,
      'password': apiData['contrasena'] ?? '',
      'creatorId': apiData['creador_id'],
      'isInProgress': apiData['torneo_en_curso'] ?? false
    };
  }

  String _getStatus(Map<String, dynamic> tournament) {
    if (tournament['ganador_id'] != null) return 'Terminado';
    if (tournament['fecha_inicio'] == null) return 'Abierto';
    final startDate = DateTime.parse(tournament['fecha_inicio']);
    return DateTime.now().isBefore(startDate) 
      ? 'Abierto' 
      : 'En progreso';
    }

  void _handleCreateTournament(
    String name, 
    String password,
    String prize,
    String description
  ) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final newTournament = await api.createTournament(
        name,
        password.isNotEmpty ? password : null,
        prize, 
        description
      );

      setState(() {
        User().torneo_id = newTournament['id'];
        _allTournaments.insert(0, _formatTournament(newTournament));
        _filteredTournaments = List.from(_allTournaments);
      });

      Navigator.pop(context);
      _redirectToUserTournament();
      showCustomSnackBar(
        type: SnackBarType.success,
        message: "Torneo creado",
        duration: 3
      );
    } catch (e) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: _parseErrorMessage(e),
        duration: 5
      );
    }
  }

  String _parseErrorMessage(Object e) {
    final error = e.toString();
    if (error.contains('nombre')) return 'Nombre inválido (3-50 caracteres)';
    if (error.contains('premio')) return 'Premio inválido (Número)';
    if (error.contains('descripcion')) return 'URL inválida';
    return "Error creando torneo: ${error.replaceAll("Exception: ", "")}";
  }

  void _handleJoinTournament(String tournamentId, String password) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final success = await api.joinTournament(tournamentId, password.isNotEmpty ? password : null);
      
      if(success) {
        setTournament(int.parse(tournamentId));
        Navigator.pop(context);
        _redirectToUserTournament();
      }
    } catch (e) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: e.toString().replaceAll("Exception: ", ""),
        duration: 5
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
    final TextEditingController prizeController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    if (value.length < 3) {
                      return 'Mínimo 3 caracteres';
                    }
                    if (value.length > 50) {
                      return 'Máximo 50 caracteres';
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
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length > 100) {
                        return 'Máximo 100 caracteres';
                      }
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Contraseña (opcional)",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: prizeController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El premio es obligatorio';
                    }
                    if (num.tryParse(value) == null) {
                      return 'El premio debe ser un número válido';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Premio",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Descripción",
                    border: OutlineInputBorder(),
                    hintText: "El mejor torneo",
                  ),
                ),
              ],
            ),
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
                  passwordController.text,
                  prizeController.text,
                  descriptionController.text
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

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

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
                                "No hay torneos activos", 
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
          if(!_loading)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: 
                  CloseButtonWidget(
                    size: 60,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}