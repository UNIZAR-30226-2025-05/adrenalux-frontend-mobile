import 'package:adrenalux_frontend_mobile/constants/keys.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockSocketService extends Mock implements SocketService {
  final Map<String, dynamic> emittedEvents = {};
  final Map<String, List<Function>> listeners = {};
  
  Function(PlayerCard)? _onOpponentCardSelected;
  Function(Map<String, bool>)? _onConfirmationsUpdated;

  BuildContext? get safeContext => navigatorKey.currentContext;

  @override
  Function(PlayerCard)? get onOpponentCardSelected => _onOpponentCardSelected;

  @override
  set onOpponentCardSelected(Function(PlayerCard)? handler) {
    _onOpponentCardSelected = handler;
    if (handler != null) {
      on('cards_selected', (data) {
        final card = PlayerCard.fromJson(data['card']);
        handler(card);
      });
    }
  }

  @override
  Function(Map<String, bool>)? get onConfirmationsUpdated => _onConfirmationsUpdated;

  @override
  set onConfirmationsUpdated(Function(Map<String, bool>)? handler) {
    _onConfirmationsUpdated = handler;
    if (handler != null) {
      on('confirmation_updated', (data) {
        final confirmations = Map<String, bool>.from(data['confirmations']);
        handler(confirmations);
      });
    }
  }

  @override 
  void sendSurrender(int matchId) {
    emittedEvents['surrender'] = {'matchId': matchId};
  }

  @override
  void sendPauseRequest(int matchId) {
    emittedEvents['request_pause'] = {'matchId': matchId};
  }
  
  @override
   void joinMatchmaking() {
    emittedEvents['join_matchmaking'] = {true};
  }

  @override
  void selectMatchCard(String cardId, String skill) {
    final matchProvider = Provider.of<MatchProvider>(safeContext!, listen: false);
    final newRound = RoundInfo(
      roundNumber: matchProvider.currentRound!.roundNumber,
      isUserTurn: false,
      phase: 'response',
    );
    matchProvider.updateRound(newRound);

    emittedEvents['select_card'] =  {
      'cartaId': cardId,
      'skill': skill,
    };  
  }

  @override
  void selectMatchResponse(String cardId, String skill) {
    emittedEvents['select_response'] =  {
      'cartaId': cardId,
      'skill': skill,
    };  
  }

  @override
   void leaveMatchmaking() {
    emittedEvents['leaveMatchmaking'] = {true};
  }

  @override
  void sendExchangeRequest(String receptorId, String username) {
    emittedEvents['request_exchange'] = {'receptorId': receptorId, 'username': username};
  }

  @override
  void cancelExchangeRequest(String exchangeId) {
    emittedEvents['decline_exchange'] = {'exchangeId': exchangeId };
  }

  @override
  void selectCard(String exchangeId, int cardId) {
    emittedEvents['select_cards'] = {'exchangeId': exchangeId, 'cardId': cardId};
  }

  @override
  void confirmExchange(String exchangeId) {
    emittedEvents['confirm_exchange'] = {'exchangeId': exchangeId };
  }

  @override
  void cancelConfirmation(String exchangeId) {
    emittedEvents['cancel_confirmation'] = {'exchangeId': exchangeId };
  }

  @override
  void cancelExchange(String exchangeId) {
    emittedEvents['cancel_exchange'] = {'exchangeId': exchangeId };
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