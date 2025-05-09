import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:adrenalux_frontend_mobile/services/api_service.dart';

class DraftsScreen extends StatefulWidget {
  @override
  _DraftsScreenState createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  late ApiService apiService;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSelectingTemplate = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false); 
    _loadPlantillas();
  }

  Future<void> _loadPlantillas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plantillas = await apiService.getPlantillas();
      if (plantillas != null) {
        User().drafts = plantillas;
      }
    } catch (e) {
      setState(() {
        _errorMessage = '${AppLocalizations.of(context)!.error_loading_templates} ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCreateTemplateDialog() {
    final TextEditingController _controller = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.new_template),
        content: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            controller: _controller,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.template_name_hint,
              errorMaxLines: 2,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.nameRequired;
              } else if (value.length <= 3) {
                return AppLocalizations.of(context)!.invalidNameError;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            key: Key('confirm_create_template'),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final newDraft = Draft(name: _controller.text, draft: {});
                Navigator.pop(context);
                _navigateToTemplateScreen(newDraft);
              }
            },
            child: Text(AppLocalizations.of(context)!.create),
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
    ).then((_) => _loadPlantillas());
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectingTemplate = !_isSelectingTemplate;
    });
  }

  void _selectDraft(Draft draft) {
    setState(() {
      apiService.activarPlantilla(draft.id);
      setSelectedDraft(draft.id!);
      _isSelectingTemplate = false;
    });
  }


  Widget _buildActiveTemplatePanel(BuildContext context, ScreenSize screenSize, ThemeData theme) {
    final activeDraft = User().currentSelectedDraft;
    final bool isInvalidDraft = activeDraft.id == -1;
    final draftCards = isInvalidDraft ? [] : activeDraft.draft.values.toList();
    
    return GestureDetector(
      key: Key('active_template_panel'),
      onTap: _toggleSelectionMode,
      child: Panel(
        width: screenSize.width * 0.3,
        height: screenSize.height * 0.125,
        content: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.02,
            vertical: screenSize.height * 0.005,
          ),
          child: isInvalidDraft 
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.no_draft_selected,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: screenSize.height * 0.005),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                activeDraft.name.isNotEmpty 
                                    ? activeDraft.name 
                                    : AppLocalizations.of(context)!.no_templates,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          SizedBox(width: screenSize.width * 0.01),
                          Icon(
                            _isSelectingTemplate ? Icons.cancel : Icons.check_circle,
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

  void _deleteDraft(int? id) async {
    if(id == null) {return;}

    final success = await apiService.deletePlantilla(id);

    if(success) {
      setState(() {
        deleteDraft(id);
      });
      showCustomSnackBar(type: SnackBarType.info, message: AppLocalizations.of(context)!.template_deleted, duration: 5);
    }else {
      showCustomSnackBar(type: SnackBarType.error, message: AppLocalizations.of(context)!.error_deleting_template, duration: 5);
    }
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
    int? draftId = User().currentSelectedDraft.id;


    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.drafts,
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
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          
          if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
          
          if (!_isLoading && _errorMessage == null)
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
                                      key: Key('create_template_button'),
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
                                            AppLocalizations.of(context)!.select_a_template,
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
                                            key: Key('no_templates_message'),
                                            AppLocalizations.of(context)!.no_templates_created,
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
                                              key: Key('draft_template_${draftTemplate.id}'),
                                              onTap: _isSelectingTemplate
                                                  ? () => _selectDraft(draftTemplate)
                                                  : null,
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: screenSize.height * 0.005),
                                                decoration: BoxDecoration(
                                                  color: _isSelectingTemplate &&
                                                          draftTemplate.id ==
                                                              draftId
                                                      ? theme.colorScheme.primary.withOpacity(0.2)
                                                      : listItemBackground,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: _isSelectingTemplate &&
                                                          draftTemplate.id ==
                                                              draftId
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
                                                            onTap: _isSelectingTemplate ? null : () => _deleteDraft(draftTemplate.id),
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