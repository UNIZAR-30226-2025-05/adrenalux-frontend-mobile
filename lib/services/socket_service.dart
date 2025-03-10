import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/constants/keys.dart';
import 'package:adrenalux_frontend_mobile/screens/social/exchange_screen.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;
  
  factory SocketService() => _instance;
  
  SocketService._internal();

  BuildContext? get safeContext => navigatorKey.currentContext;

  Function(PlayerCard)? onOpponentCardSelected;
  Function(Map<String, bool>)? onConfirmationsUpdated;

  void initialize(BuildContext safeContext) {
    _connect(safeContext);
  }

  Future<void> _connect(safeContext) async {
    final token = await getToken();
    print("Username: ${User().name}");
    
    _socket = IO.io(
      'http://54.37.50.18:3000',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setQuery({
          'username': User().name,
        })
        .setAuth({'token': token})
        .build(),
    );

    _socket?.onConnect((_) {
      print('Conectado al socket');
      _setupExchangeListeners(); 
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
    _socket?.on('exchange_accepted', (data) => _handleExchangeAccepted(data));
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
        Navigator.of(safeContext!).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MenuScreen(),
          ),
        );
      }
  }

  void _handleExchangeCancelled(dynamic data) {
      if (safeContext != null && safeContext!.mounted) {
        showCustomSnackBar(
          type: SnackBarType.info,
          message: 'Intercambio cancelado',
        );
        Navigator.of(safeContext!).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MenuScreen(),
          ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

        showCustomSnackBar(
          type: snackType,
          message: message,
          duration: 5,
          actionLabel: actionLabel,
          onAction: onAction,
        );

      } catch (e) {}
    });
  }

  void _handleIncomingRequest(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCustomSnackBar(
        type: SnackBarType.info,
        message: AppLocalizations.of(safeContext!)!.exchange_invitation + ' ${data['solicitanteUsername']}',
        actionLabel: 'Aceptar',
        onAction: () => acceptExchangeRequest(data['exchangeId']),
      );
    });
  }

  void _handleExchangeAccepted(Map<String, dynamic> data) {
    final myUsername = User().name;
    final solicitanteUsername = data['solicitanteUsername'];
    final receptorUsername = data['receptorUsername'];

    final username = (myUsername == solicitanteUsername)
        ? receptorUsername
        : solicitanteUsername;

    print("Data: $data");
    if (safeContext != null && safeContext!.mounted) {
      _navigateToExchangeScreen(safeContext!, data['exchangeId'], username);
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

  void _navigateToExchangeScreen(BuildContext safeContext, String exchangeId, String username) {

    if (Navigator.canPop(safeContext)) {
      Navigator.pop(safeContext);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (safeContext.mounted) {
        Navigator.of(safeContext, rootNavigator: true).pop();
        Navigator.push(
          safeContext,
          MaterialPageRoute(builder: (_) => ExchangeScreen(exchangeId: exchangeId, opponentUsername: username)),
        );
      } else {
        print('Context not available for navigation');
      }
    });
  }

  Future<void> _handleAcceptRequest(String requestId, BuildContext safeContext) async {
    try {
      final success = await acceptRequest(requestId);
      
      if (success && safeContext.mounted) {
        showCustomSnackBar(
          type: SnackBarType.success,
          message:  AppLocalizations.of(safeContext)!.exchange_accepted,
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
}