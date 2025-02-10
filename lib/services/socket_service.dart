import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  SocketService() {
    _connect();
  }

  Future<void> _connect() async {
    final String? token = await getToken();

    if (token == null) {
      print("No hay token disponible.");
      return;
    }

    socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token} // Enviar el JWT en la autenticación
    });

    socket.connect();
  }
  
  void disconnect() {
    socket.disconnect();
  }
}
