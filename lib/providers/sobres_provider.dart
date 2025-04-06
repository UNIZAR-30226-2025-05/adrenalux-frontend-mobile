import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:provider/provider.dart';

class SobresProvider extends ChangeNotifier {
  late ApiService apiService;
  List<Sobre> _sobres = [];

  List<Sobre> get sobres => _sobres;

  Future<void> cargarSobres(BuildContext context) async {
    apiService = Provider.of<ApiService>(context, listen: false);
    if (_sobres.isNotEmpty) return; 

    final fetchedSobres = await apiService.getSobresDisponibles();
    _sobres = fetchedSobres ?? []; 
    notifyListeners();
  }
}