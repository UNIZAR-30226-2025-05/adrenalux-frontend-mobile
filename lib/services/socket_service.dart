import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/plantilla.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/game/match_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/constants/keys.dart';
import 'package:adrenalux_frontend_mobile/screens/social/exchange_screen.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SocketService {
  ApiService apiService = ApiService();
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;
  bool _isInitialized = false;
  
  factory SocketService() => _instance;
  
  SocketService._internal();

  BuildContext? get safeContext => navigatorKey.currentContext;

  Function(PlayerCard)? onOpponentCardSelected;
  Function(Map<String, bool>)? onConfirmationsUpdated;

  static final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
  String? currentRouteName;

  static const Set<String> _blockedRoutes = {
    '/match', 
    '/open_pack',
    '/exchange'
  };

  void _setupMatchListeners() {
    _socket?.on('match_found', (data) => _handleMatchFound(data));
    _socket?.on('round_start', (data) => _handleRoundStart(data));
    _socket?.on('opponent_selection', (data) => _handleOpponentSelection(data));
    _socket?.on('round_result', (data) => _handleRoundResult(data));
    _socket?.on('match_ended', (data) => _handleMatchEnded(data));
    _socket?.on('match_resumed', (data) => _handleMatchResumed(data));
    _socket?.on('match_paused', (data) => _handleMatchPaused(data));
    _socket?.on('pause_requested', (data) => _handlePauseRequested(data));
    _socket?.on('resume_confirmation', (data) => _handleResumeConfirmation(data));
  }

  void updateCurrentRoute(Route<dynamic> route) {
    if (route is PageRoute) {
      currentRouteName = route.settings.name;
    }
  }

  void initialize(BuildContext safeContext) {
    if (!_isInitialized) { 
      _connect(safeContext);
      _isInitialized = true;
    }
  }

  bool _shouldBlockNotifications() {
    if (safeContext == null || !safeContext!.mounted) {
      currentRouteName = null;
      return true;
    }
    print("Route $currentRouteName");
    return currentRouteName != null && _blockedRoutes.contains(currentRouteName);
  }

  Future<void> _connect(safeContext) async {
    final token = await apiService.getToken();
    
    _socket = IO.io(
      'https://adrenalux.duckdns.org', 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setPath('/socket.io') 
        .setQuery({'username': User().name})
        .setAuth({'token':token})
        .enableForceNew()
        .build(),
    );

    _socket?.onConnect((_) {
      print('Conectado al socket');
      _setupExchangeListeners(); 
      _setupMatchListeners();
    });

    
    _socket?.on('notification', (data) => _handleNotification(data));

    _socket?.onConnectError((error) {
      print('Error de conexión: $error');
    });

    _socket?.onConnectTimeout((_) {
      print('Tiempo de conexión agotado');
    });
  }

  void _setupExchangeListeners() {
    _socket?.on('request_exchange_received', (data) => _handleIncomingRequest(data));
    _socket?.on('exchange_accepted', (data) => handleExchangeAccepted(data));
    _socket?.on('exchange_declined', (data) => _handleExchangeRejected(data));
    _socket?.on('error', (data) => _handleExchangeError(data));
    _socket?.on('cards_selected', (data) => _handleCardsSelected(data));
    _socket?.on('confirmation_updated', (data) => _handleConfirmationUpdate(data));
    _socket?.on('exchange_completed', (data) => _handleExchangeCompleted(data));
    _socket?.on('exchange_cancelled', (data) => _handleExchangeCancelled(data));
  }

  /*
   * Funciones para tratar mensajes entrantes 
   * 
   * 
   */

  void _handleExchangeCompleted(dynamic data) {
      if (safeContext != null && safeContext!.mounted) {
        showCustomSnackBar(
          type: SnackBarType.success,
          message: '¡Intercambio completado con éxito!',
        );
        Navigator.of(safeContext!, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MenuScreen()),
          (route) => false,
        );
      }
  }

  void _handleExchangeCancelled(dynamic data) {
    Navigator.of(safeContext!, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MenuScreen()),
      (route) => false,
    );
    if (safeContext != null && safeContext!.mounted) {
      showCustomSnackBar(
        type: SnackBarType.info,
        message: AppLocalizations.of(safeContext!)!.exchange_canceled,
      );
    }
  }

  void _handleConfirmationUpdate(dynamic data) {
      if (safeContext != null && safeContext!.mounted) {
        final confirmations = Map<String, bool>.from(data['confirmations']);
        onConfirmationsUpdated?.call(confirmations);
      }
  }

  void _handleCardsSelected(dynamic data) {
    if (safeContext != null && safeContext!.mounted) {
      final userId = data['userId'];
      final card = PlayerCard.fromJson(data['card']);
    
      if (userId != User().id.toString()) {
        onOpponentCardSelected!(card);
      }
    }
  }

  void _handleNotification(dynamic data) {
    if (_shouldBlockNotifications()) return; 

    try {
      final notificationData = data['data'] as Map<String, dynamic>;
      final type = notificationData['type'] as String;

      String message;
      SnackBarType snackType;
      String? actionLabel;
      VoidCallback? onAction; 

      switch (type) {
        case 'friend_request':
          message = data['message'];
          snackType = SnackBarType.info;
          actionLabel = 'Aceptar';
          onAction = () => _handleAcceptRequest(
            notificationData['requestId'].toString(),
            safeContext!
          );
          break;
        case 'battle':
          message = '¡${notificationData['senderName']} te desafía a un duelo!';
          snackType = SnackBarType.error;
          break;
        default:
          message = 'Nueva notificación';
          snackType = SnackBarType.info;
      }
      if (safeContext != null && safeContext!.mounted) {
        showCustomSnackBar(
          type: snackType,
          message: message,
          duration: 5,
          actionLabel: actionLabel,
          onAction: onAction,
        );
      }

    } catch (e) {}
  }

  void _handleIncomingRequest(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shouldBlockNotifications()){
        cancelExchangeRequest(data['exchangeId']);
        return;
      };
      showCustomSnackBar(
        type: SnackBarType.info,
        message: AppLocalizations.of(safeContext!)!.exchange_invitation + ' ${data['solicitanteUsername']}',
        actionLabel: 'Aceptar',
        onAction: () => acceptExchangeRequest(data['exchangeId']),
      );
    });
  }

  void handleExchangeAccepted(Map<String, dynamic> data) {
    print("Ejecutandose Exchange Accepted");
    final myUsername = User().name;
    final solicitanteUsername = data['solicitanteUsername'];
    final receptorUsername = data['receptorUsername'];

    final username = (myUsername == solicitanteUsername)
        ? receptorUsername
        : solicitanteUsername;

    if (safeContext != null && safeContext!.mounted) {
      Navigator.pop(safeContext!);
      _navigateToExchangeScreen(safeContext!, data['exchangeId'], username);
    }
  }

  Future<void> _handleAcceptRequest(String requestId, BuildContext safeContext) async {
    try {
      final success = await apiService.acceptRequest(requestId);
      
      if (success && safeContext.mounted) {
        showCustomSnackBar(
          type: SnackBarType.success,
          message:  AppLocalizations.of(safeContext)!.friend_request_accepted,
          duration: 3,
        );
      }
    } catch (e) {
      if (safeContext.mounted) {
        showCustomSnackBar(
          type: SnackBarType.error,
          message: 'Error al aceptar: ${e.toString()}',
          duration: 5,
        );
      }
    }
  }

  void _handleExchangeRejected(Map<String, dynamic> data) {
    if (safeContext != null && safeContext!.mounted) {
      Navigator.of(safeContext!, rootNavigator: true).pop();
      showCustomSnackBar(
        type: SnackBarType.info,
        message: AppLocalizations.of(safeContext!)!.exchange_declined,
      );
    }
  }

  void _handleExchangeError(String error) {
    if (safeContext != null && safeContext!.mounted) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: error,
      );
    }
  }

  void _handleMatchFound(dynamic data) {
    print("Partida encontrada $data");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shouldBlockNotifications()) return;
      
      if (safeContext != null && Navigator.canPop(safeContext!)) {
        Navigator.pop(safeContext!);
      }

      Navigator.pushReplacement(
        safeContext!,
        MaterialPageRoute(
          builder: (_) => MatchScreen(
            matchId: data['matchId'],
            userTemplate: User().selectedDraft!,
          ),
          settings: RouteSettings(name: '/game'),
        ),
      );
    });
  }


  void _handleRoundStart(dynamic data) {
    final roundInfo = RoundInfo.fromJson(data);
    final matchProvider = Provider.of<MatchProvider>(safeContext!, listen: false);

    matchProvider.updateRound(roundInfo);
  }

  void _handleOpponentSelection(dynamic data) {
    final selection = OpponentSelection.fromJson(data);
    final matchProvider = Provider.of<MatchProvider>(safeContext!, listen: false);
    
    if (matchProvider.currentRound == null || matchProvider.currentRound?.phase == 'response') {return;}

    matchProvider.updateOpponentSelection(selection);

    final newRound = RoundInfo(
      roundNumber: matchProvider.currentRound!.roundNumber,
      isUserTurn: true,
      phase: 'response',
    );
    matchProvider.updateRound(newRound);
  }

  void _handleRoundResult(dynamic data) {
    final result = RoundResult.fromJson(data);
    final matchProvider = Provider.of<MatchProvider>(safeContext!, listen: false);

    if (matchProvider.currentRound == null) {
      return;
    }

    matchProvider.updateRoundResult(result);
  }

  void _handleMatchEnded(dynamic data) {
    final result = MatchResult.fromJson(data);
    print("Resultado final: ${result}");
    
    Provider.of<MatchProvider>(safeContext!, listen: false).endMatch(result);
  }

  void _handleMatchResumed(dynamic data) {

    final user1Id = data['user1Id'] as int;
    final isUser1 = User().id == user1Id;
    final draftId = isUser1 ? data['plantilla1'] : data['plantilla2'];
    Draft? userDraft;
    
    for (var draft in User().drafts) {
      if (draft.id == draftId) {
        userDraft = draft;
        break;
      }
    }

    if (userDraft == null) {
      throw Exception('No matching draft found for the given draftId: $draftId');
    }


    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        safeContext!,
        MaterialPageRoute(
          builder: (_) => MatchScreen(
            matchId: data['matchId'],
            userTemplate: userDraft!,
            resumedData: data,
          ),
        ),
      );
    });
  }

  void _handleMatchPaused(dynamic data) {
    final matchProvider = Provider.of<MatchProvider>(safeContext!, listen: false);
    matchProvider.reset();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (safeContext != null && safeContext!.mounted) {
        Navigator.of(safeContext!, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MenuScreen()),
          (route) => false,
        );
        showCustomSnackBar(
          type: SnackBarType.info,
          message: 'Partida pausada',
          duration: 3,
        );
      }
    });
  }

  void _handlePauseRequested(dynamic data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shouldBlockNotifications()) return;

      showCustomSnackBar(
        type: SnackBarType.info,
        message: 'Solicitud de pausa recibida',
        actionLabel: 'Aceptar',
        onAction: () => sendPauseRequest(data['matchId']),
        duration: 10,
      );
    });
  }

  void _handleResumeConfirmation(dynamic data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shouldBlockNotifications()) return;

      showCustomSnackBar(
        type: SnackBarType.info,
        message: 'Solicitud de reanudación recibida',
        actionLabel: 'Aceptar',
        onAction: () => sendResumeRequest(data['matchId']),
        duration: 10,
      );
    });
  }

  /*
   *  Funciones para emitir mensajes por websockets
   * 
   */

  void confirmExchange(String exchangeId) {
    _socket?.emit('confirm_exchange', exchangeId);
  }

  void cancelConfirmation(String exchangeId) {
    _socket?.emit('cancel_confirmation', exchangeId);
  }

  void cancelExchange(String exchangeId) {
    _socket?.emit('cancel_exchange', exchangeId);
  }

  void selectCard(String exchangeId, int cardId) {
    _socket?.emit('select_cards', {'exchangeId': exchangeId, 'cardId': cardId});
  }

  void sendExchangeRequest(String receptorId, String username) {
    _socket?.emit('request_exchange', {'receptorId': receptorId, 'solicitanteUsername' : username});
  }

  void acceptExchangeRequest(String exchangeId) {
    _socket?.emit('accept_exchange', exchangeId);
  }

  void cancelExchangeRequest(String exchangeId) {
    _socket?.emit('decline_exchange', exchangeId);
  }

  void joinMatchmaking() {
    print("Entrando al matchmaking");
    _socket?.emit('join_matchmaking');
  }

  void leaveMatchmaking() {
    _socket?.emit('leave_matchmaking');
  }

  void selectMatchCard(String cardId, String skill) {
    final matchProvider = Provider.of<MatchProvider>(safeContext!, listen: false);
    final newRound = RoundInfo(
      roundNumber: matchProvider.currentRound!.roundNumber,
      isUserTurn: false,
      phase: 'response',
    );
    matchProvider.updateRound(newRound);

    _socket?.emit('select_card', {
      'cartaId': cardId,
      'skill': skill,
    });
  }

  void selectMatchResponse(String cardId, String skill) {
    _socket?.emit('select_response', {
      'cartaId': cardId,
      'skill': skill,
    });
  }

  void sendPauseRequest(int matchId) {
    print("Mandando solicitud de pausa ${matchId}");
    _socket?.emit('request_pause', {'matchId': matchId});
  }

  void sendResumeRequest(int matchId) {
    print("Mandando solicitud de continuacion ${matchId}");
    _socket?.emit('request_resume', {'matchId': matchId});
  }

  void cancelResumeRequest() {
    _socket?.emit('cancel_request_resume');
  }

  void sendSurrender(int matchId) {
    print("MatchId: $matchId");
  _socket?.emit('surrender', {'matchId': matchId});
  }

  void requestResumeMatch(int matchId) {
    _socket?.emit('request_resume', {'matchId': matchId});
  }

  void _navigateToExchangeScreen(BuildContext safeContext, String exchangeId, String username) {

    if (Navigator.canPop(safeContext)) {
      Navigator.of(safeContext).popUntil((route) => route.isFirst);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (safeContext.mounted) {
        Navigator.of(safeContext).popUntil((route) => route.isFirst);
        Navigator.push(
          safeContext,
          MaterialPageRoute(
            builder: (_) => ExchangeScreen(exchangeId: exchangeId, opponentUsername: username),
            settings: RouteSettings(name: '/exchange'),
          ),
        );
      } else {
        print('Context not available for navigation');
      }
    });
  }
}