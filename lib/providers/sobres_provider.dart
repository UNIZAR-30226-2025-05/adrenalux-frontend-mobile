import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';

class SobresProvider extends ChangeNotifier {
  List<Sobre> _sobres = [];

  List<Sobre> get sobres => _sobres;

  Future<void> cargarSobres() async {
    if (_sobres.isNotEmpty) return; 

    _sobres = await getSobresDisponibles();
    print("Sobres: " + _sobres.length.toString());
    notifyListeners();
  }
}