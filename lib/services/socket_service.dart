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

  Future<void> _connect(BuildContext context) async {
    final token = await getToken();
    
    _socket = IO.io(
      'http://10.0.2.2:3000',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setAuth({'token': token})
        .build(),
    );

    _socket?.onConnect((_) => print('Conectado al socket'));
    
    _socket?.on('notification', (data) => _handleNotification(data, context));

    _socket?.onConnectError((error) {
      print('Error de conexión: $error');
    });

    _socket?.onConnectTimeout((_) {
      print('Tiempo de conexión agotado');
    });
  }

  

  void _handleNotification(dynamic data, BuildContext context) {
    try {
      final type = data['type'] as String;
      final notificationData = data['data'] as Map<String, dynamic>;
      
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
        
        default:
          message = 'Nueva notificación';
          snackType = SnackBarType.info;
      }

      showCustomSnackBar(
        context,
        snackType,
        message,
        5,  
      );

    } catch (e) {
      showCustomSnackBar(
        context,
        SnackBarType.error,
        'Error al procesar notificación',
        3,
      );
    }
  }  
  void disconnect() {
    _socket?.disconnect();
  }
}
