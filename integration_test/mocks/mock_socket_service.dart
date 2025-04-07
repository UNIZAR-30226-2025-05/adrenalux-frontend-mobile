import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSocketService extends Mock implements SocketService {
  final Map<String, dynamic> emittedEvents = {};
  final Map<String, List<Function>> listeners = {};

  @override
  void sendExchangeRequest(String receptorId, String username) {
    emittedEvents['request_exchange'] = {'receptorId': receptorId, 'username': username};
  }

  @override
  void cancelExchangeRequest(String exchangeId) {
    emittedEvents['request_exchange'] = {'exchangeId': exchangeId };
  }

  void on(String event, Function handler) {
    listeners[event] = [...(listeners[event] ?? []), handler];
  }

  void emit(String event, [dynamic data]) {
    emittedEvents[event] = data;
  }

  void simulateEvent(String event, dynamic data) {
    if (listeners.containsKey(event)) {
      for (var handler in listeners[event]!) {
        handler(data);
      }
    }
  }

  void off(String event) {
    listeners.remove(event);
  }

  void dispose() {
    listeners.clear();
    emittedEvents.clear();
  }
}