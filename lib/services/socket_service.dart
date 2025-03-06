import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;
  
  factory SocketService() => _instance;
  
  SocketService._internal();

  void initialize(BuildContext context) {
    _connect(context);
  }

  Future<void> _connect(context) async {
    final token = await getToken();
    
    _socket = IO.io(
      'http://54.37.50.18:3000',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setAuth({'token': token})
        .build(),
    );

    _socket?.onConnect((_) => print('Conectado al socket'));
    
    _socket?.on('notification', (data) => _handleNotification(data));

    _socket?.onConnectError((error) {
      print('Error de conexión: $error');
    });

    _socket?.onConnectTimeout((_) {
      print('Tiempo de conexión agotado');
    });
  }

  

  void _handleNotification(dynamic data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      final notificationData = data['data'] as Map<String, dynamic>;
      final type = notificationData['type'] as String;

      String message;
      SnackBarType snackType;

      switch (type) {
        case 'exchange':
          message = 'Intercambio con ${notificationData['senderName']} pendiente';
          snackType = SnackBarType.info;
          break;
        
        case 'battle':
          message = '¡${notificationData['senderName']} te desafía a un duelo!';
          snackType = SnackBarType.error;
          break;
        case 'friend_request':
          print("Datos: $data");
          message = data['message'];
          snackType = SnackBarType.info;
          showCustomSnackBar(
            type: snackType,
            message: message,
            duration: 5,
            actionLabel: 'ACEPTAR', 
            onAction: () => _handleAcceptRequest(notificationData['requestId'].toString()),
          );
          break;
        
        default:
          message = 'Nueva notificación';
          snackType = SnackBarType.info;
      }

      

    } catch (e) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: 'Error al procesar notificación',
        duration: 3,
      );
    }
    });
  }  
  void disconnect() {
    _socket?.disconnect();
  }
}

void _handleAcceptRequest(String requestId) async {
  try {
    final success = await acceptRequest(requestId);
    if (success?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomSnackBar(
          type: SnackBarType.success,
          message: 'Solicitud aceptada',
          duration: 3,
        );
      });
    }
  } catch (e) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: 'Error al aceptar: ${e.toString()}',
        duration: 5,
      );
    });
  }
}