import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:adrenalux_frontend_mobile/constants/draft_positions.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/models/plantilla.dart';
import 'package:adrenalux_frontend_mobile/widgets/card_collection.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';

class EditDraftScreen extends StatefulWidget {
  final Draft draft;

  const EditDraftScreen({super.key, required this.draft});
  @override
  _EditDraftScreenState createState() => _EditDraftScreenState();
}

class _EditDraftScreenState extends State<EditDraftScreen> {
  late ApiService apiService;
  List<PlayerCard> _allPlayers = [];
  Map<String, PlayerCard?> _selectedPlayers = {
    'GK': null,
    'DEF1': null,
    'DEF2': null,
    'DEF3': null,
    'DEF4': null,
    'MID1': null,
    'MID2': null,
    'MID3': null,
    'FWD1': null,
    'FWD2': null,
    'FWD3': null,
  };

  List<PlayerCard> _filteredPlayers = [];
  String? _currentPosition;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false); 
    _selectedPlayers = widget.draft.draft;
    _loadPlayers();
  }

  void _saveTemplate() async {
    if (_isSaving) return; 
    setState(() => _isSaving = true); 

    if (_selectedPlayers.values.any((player) => player == null)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.template_incomplete),
          content: Text(AppLocalizations.of(context)!.template_incomplete_message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final createResponse = await apiService.createPlantilla(widget.draft);
      if (! createResponse) {
        throw Exception(AppLocalizations.of(context)!.error_creating_template);
      }
      
      setState(() => _hasUnsavedChanges = false);
      Navigator.pop(context);

      showCustomSnackBar(type: SnackBarType.success, message: AppLocalizations.of(context)!.template_created_success, duration: 3);
      
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.error_saving),
          content: Text('${AppLocalizations.of(context)!.error_saving_message} ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false); 
      }
    }
  }

  void _loadPlayers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      List<PlayerCard> players = await apiService.getCollection();
      
      if (!mounted) return;
      setState(() {
        _allPlayers = players;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.error_loading_players;
        _isLoading = false;
      });
    }
  }

  bool get _isTemplateComplete {
    return _selectedPlayers.values.every((player) => player != null) 
        && _selectedPlayers.length == 11; 
  }

  List<PlayerCard> _getPlayersByPosition(String position) {
    return _allPlayers.where((player) => player.position == position).toList();
  }

  void _handlePositionTap(String position) {
    setState(() {
      _currentPosition = position;
      String playerPosition = _mapTemplatePositionToPlayerPosition(position);
      List<PlayerCard> playersByPosition = _getPlayersByPosition(playerPosition);

      List<PlayerCard> allSelectedPlayers = _selectedPlayers.entries
          .where((entry) => entry.value != null)
          .map((entry) => entry.value!)
          .toList();

      _filteredPlayers = playersByPosition
          .where((player) => !allSelectedPlayers.any((selectedPlayer) =>
              selectedPlayer.playerName == player.playerName &&
              selectedPlayer.playerSurname == player.playerSurname))
          .toList();
    });
    _showPlayerSelectionPanel();
  }



  String _mapTemplatePositionToPlayerPosition(String templatePosition) {
    if (templatePosition == 'GK') return 'goalkeeper';
    if (templatePosition.startsWith('DEF')) return 'defender';
    if (templatePosition.startsWith('MID')) return 'midfielder';
    return 'forward';
  }

  void _showPlayerSelectionPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSelectionPanel(),
    );
  }

  Widget _buildSelectionPanel() {
    final screenSize = ScreenSize.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.7,
      child: Panel(
        height: screenSize.height * 0.45,
        width: screenSize.width * 0.9,
        content: Column(
          children: [
            SizedBox(height: 10),
            Text(
              '${AppLocalizations.of(context)!.select_player} ($_currentPosition)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CustomSearchMenu<PlayerCard>(
              items: _filteredPlayers, 
              getItemName: (player) => '${player.playerName} ${player.playerSurname}',
              onFilteredItemsChanged: (filtered) =>
                  setState(() => _filteredPlayers = filtered),
            ),
            Expanded(
              child: CardCollection(
                playerCardWidgets: _filteredPlayers
                    .map((player) => PlayerCardWidget(
                          playerCard: player,
                          size: "sm",
                        ))
                    .toList(),
                onCardTap: (player) => _selectPlayer(player),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPlayer(PlayerCard player) {
    setState(() {
      _selectedPlayers[_currentPosition!] = player;
      _hasUnsavedChanges = true;
    });
    Navigator.pop(context);
  }

  Future<void> _confirmExit() async {
    if (!_hasUnsavedChanges) {
      Navigator.pop(context);
      return;
    }

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        key: Key('exit-dialog'),
        title: Text(AppLocalizations.of(context)!.exit_without_saving),
        content: Text(AppLocalizations.of(context)!.unsaved_changes_warning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.exit),
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
          title: Center(
            child: Padding(
              padding: EdgeInsets.only(left: screenSize.width * 0.25),
              child: Text(
                AppLocalizations.of(context)!.draft,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: screenSize.height * 0.03,
                ),
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              key: Key('save-button'),
              icon: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(Icons.save),
              color: _isTemplateComplete && !_isSaving
                  ? theme.colorScheme.primary
                  : theme.disabledColor,
              onPressed: _isTemplateComplete && !_isSaving ? _saveTemplate : null,
            ),
            IconButton(
              icon: Icon(Icons.close),
              color: theme.colorScheme.primary,
              onPressed: _confirmExit,
            ),
          ],
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
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(child: Text(_errorMessage!))
          else
            FieldTemplate(
              draft: Draft(
                id : widget.draft.id,
                name: widget.draft.name,
                draft: _selectedPlayers,
              ),
              isInteractive: true,
              onCardTap: (player, position) => _handlePositionTap(position!),
            ),
        ],
      ),
    );
  }
}