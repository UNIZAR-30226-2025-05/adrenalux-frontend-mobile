import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/game/edit_draft_screen.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/models/plantilla.dart';
import 'package:adrenalux_frontend_mobile/constants/empty_card.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';

class DraftsScreen extends StatefulWidget {
  @override
  _DraftsScreenState createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSelectingTemplate = false;

  void _showCreateTemplateDialog() {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva plantilla'),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: 'Nombre de la plantilla'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                final newDraft = Draft(name: _controller.text, draft: {});
                setSelectedDraft(newDraft);
                Navigator.pop(context);
                _navigateToTemplateScreen(newDraft);
              }
            },
            child: Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _navigateToTemplateScreen(Draft draft) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDraftScreen(draft: draft),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectingTemplate = !_isSelectingTemplate;
    });
  }

  void _selectDraft(Draft draft) {
    setSelectedDraft(draft);
    Navigator.pop(context);
  }

  Widget _buildActiveTemplatePanel(BuildContext context, ScreenSize screenSize, ThemeData theme) {
    final activeDraftName = User().selectedDraft.name;
    final draftCards = User().selectedDraft.draft.values.toList();
    return GestureDetector(
      onTap: _toggleSelectionMode,
      child: Panel(
        width: screenSize.width * 0.3,
        height: screenSize.height * 0.125,
        content: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.02,
            vertical: screenSize.height * 0.005,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenSize.height * 0.005),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      activeDraftName.isNotEmpty ? activeDraftName : 'Sin plantillas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.01),
                    Icon(
                      activeDraftName.isNotEmpty
                          ? (_isSelectingTemplate ? Icons.cancel : Icons.check_circle)
                          : null,
                      color: _isSelectingTemplate ? Colors.orange : Colors.green,
                      size: screenSize.height * 0.01,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.height * 0.005),
              Expanded(
                child: SizedBox(
                  height: screenSize.height * 0.08,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: List.generate(3, (index) {
                      final card = index < draftCards.length ? draftCards[index] : null;
                      final panelWidth = screenSize.width * 0.4;
                      final cardWidth = panelWidth * 0.2;
                      final totalOffset = cardWidth * 0.3;
                      return Positioned(
                        left: (panelWidth * 0.275) - (index * totalOffset),
                        child: PlayerCardWidget(
                          playerCard: card ?? returnEmptyCard(),
                          size: 'sm-',
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
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
    Color panelBackground = theme.colorScheme.surface;
    Color listItemBackground = panelBackground.withOpacity(0.8);
    final templates = User().drafts;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        title: Center(
          child: Text(
            'Plantillas',
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: screenSize.height * 0.03,
            ),
          ),
        ),
        centerTitle: true,
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
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.05),
                child: Column(
                  children: [
                    Center(
                      child: Panel(
                        width: screenSize.width * 0.9,
                        height: screenSize.height * 0.6,
                        content: Padding(
                          padding: EdgeInsets.all(screenSize.width * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.add,
                                      size: screenSize.height * 0.025,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                    label: Text(
                                      "Crear plantilla",
                                      style: TextStyle(
                                        fontSize: screenSize.height * 0.016,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: theme.colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: _showCreateTemplateDialog,
                                  ),
                                  SizedBox(width: screenSize.width * 0.03),
                                  Visibility(
                                    visible: _isSelectingTemplate,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Selecciona una plantilla',
                                          style: TextStyle(
                                            fontSize: screenSize.height * 0.015,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                              templates.isEmpty
                                  ? Expanded(
                                      child: Center(
                                        child: Text(
                                          "No hay plantillas creadas",
                                          style: TextStyle(
                                            fontSize: screenSize.height * 0.025,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: ListView.builder(
                                        itemCount: templates.length,
                                        itemBuilder: (context, index) {
                                          final draftTemplate = templates[index];
                                          return GestureDetector(
                                            onTap: _isSelectingTemplate
                                                ? () => _selectDraft(draftTemplate)
                                                : null,
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: screenSize.height * 0.005),
                                              decoration: BoxDecoration(
                                                color: _isSelectingTemplate &&
                                                        draftTemplate.name ==
                                                            User().selectedDraft.name
                                                    ? theme.colorScheme.primary.withOpacity(0.2)
                                                    : listItemBackground,
                                                borderRadius: BorderRadius.circular(10),
                                                border: _isSelectingTemplate &&
                                                        draftTemplate.name ==
                                                            User().selectedDraft.name
                                                    ? Border.all(color: theme.colorScheme.primary)
                                                    : null,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(screenSize.width * 0.02),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: SizedBox(
                                                        height: screenSize.height * 0.08,
                                                        child: Stack(
                                                          alignment: Alignment.center,
                                                          clipBehavior: Clip.none,
                                                          children: List.generate(3, (index) {
                                                            final card = draftTemplate.draft.values
                                                                .toList()[index];
                                                            final cardOffset = -10.0;
                                                            return Positioned(
                                                              left: screenSize.width * 0.075,
                                                              child: Transform.translate(
                                                                offset: Offset(index * cardOffset, 0),
                                                                child: PlayerCardWidget(
                                                                  playerCard: card!,
                                                                  size: 'sm-',
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            left: screenSize.width * 0.001),
                                                        child: Text(
                                                          draftTemplate.name,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                            color: theme.colorScheme.onSurface,
                                                          ),
                                                          textAlign: TextAlign.start,
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: _isSelectingTemplate
                                                              ? null
                                                              : () => _navigateToTemplateScreen(draftTemplate),
                                                          child: Padding(
                                                            padding: EdgeInsets.symmetric(
                                                                horizontal: screenSize.width * 0.025),
                                                            child: Icon(
                                                              Icons.edit,
                                                              color: _isSelectingTemplate
                                                                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                                                                  : theme.colorScheme.primary,
                                                              size: screenSize.height * 0.025,
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: _isSelectingTemplate ? null : () {},
                                                          child: Padding(
                                                            padding: EdgeInsets.symmetric(
                                                                horizontal: screenSize.width * 0.025),
                                                            child: Icon(
                                                              Icons.delete,
                                                              color: _isSelectingTemplate
                                                                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                                                                  : theme.colorScheme.error,
                                                              size: screenSize.height * 0.025,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Center(
                      child: _buildActiveTemplatePanel(context, screenSize, theme),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: padding,
            left: padding * 2,
            right: padding * 2,
            child: GestureDetector(
              onTap: _isSelectingTemplate ? _toggleSelectionMode : () => Navigator.pop(context),
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
                    _isSelectingTemplate ? Icons.cancel : Icons.close,
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
