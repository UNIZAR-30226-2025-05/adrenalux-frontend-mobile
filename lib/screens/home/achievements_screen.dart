import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:adrenalux_frontend_mobile/widgets/close_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final user = User();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait = constraints.maxHeight > constraints.maxWidth;
        final textScale = MediaQuery.textScaleFactorOf(context).clamp(0.8, 1.2);

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: textScale),
          child: Scaffold(
            appBar: _buildAppBar(theme, constraints),
            body: Stack(
              children: [
                _buildBackground(),
                _buildContent(constraints, isPortrait, user, theme),
                Positioned(
                  bottom: 20, 
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CloseButtonWidget(
                      size: 60,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, BoxConstraints constraints) {
    return PreferredSize(
      preferredSize: Size.fromHeight(constraints.maxHeight * 0.0825),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.achievements,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/soccer_field.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints, bool isPortrait, User user, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          bottom: 60,
          left: isPortrait ? 16 : 24,
          right: isPortrait ? 16 : 24,
        ),
        child: Panel(
          width: double.infinity,
          height: constraints.maxHeight * 0.75,
          content: Container(
            padding: const EdgeInsets.all(20),
            child: user.logros.isEmpty
                ? _buildEmptyState(theme)
                : _buildAchievementsList(user, theme, isPortrait),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            key: Key('empty-achievements-icon'),
            Icons.emoji_events_outlined,
            size: 80, color: theme.colorScheme.onSurface.withOpacity(0.3)
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.no_achievements,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(User user, ThemeData theme, bool isPortrait) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: user.logros.length,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (context, index) => _buildAchievementItem(user.logros[index], theme, isPortrait),
    );
  }

  Widget _buildAchievementItem(Logro logro, ThemeData theme, bool isPortrait) {
    return Container(
      key: Key('achievement-item-${logro.id}'),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isPortrait ? 15 : 20),
        child: Row(
          children: [
            Container(
              width: isPortrait ? 50 : 60,
              height: isPortrait ? 50 : 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surfaceContainerHighest,
                    theme.colorScheme.surfaceContainerHigh,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                color: const Color(0xFFFFD700), 
                size: isPortrait ? 30 : 35,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                logro.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}