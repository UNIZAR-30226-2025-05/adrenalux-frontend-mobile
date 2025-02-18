import 'dart:convert';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adrenalux_frontend_mobile/screens/auth/sign_in_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

final String baseUrl = 'http://10.0.2.2:3000/api/v1';

Future<int?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token != null) {
    final decodedToken = JwtDecoder.decode(token);
    print('Dec token: $decodedToken');
    return decodedToken['id']; 
  }

  return null;
}

Future<Map<String, dynamic>> signUp(String name, String email, String password, String password2) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/sign-up'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username' : name,'email': email, 'password': password}),
  );
  final responseBody = jsonDecode(response.body);

  return {
    'statusCode': response.statusCode,  
    'data': responseBody             
  };
}

Future<Map<String, dynamic>> signIn(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/sign-in'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final token = data['data']['token'];
    print('Token $token');
    if (data['data']['token'] != null) {
      // Guardar el token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['data']['token']);
      return data;
    } else {
      throw Exception('No se recibió un token válido');
    }
  } else {
    throw Exception(jsonDecode(response.body)['message'] ?? 'Error desconocido');
  }
}

Future<void> signOut(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token'); 
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SignInScreen()),
  );
}


Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); 
}

Future<bool> validateToken() async {
  final token = await getToken();

  print('token $token');
  if (token == null) {
    return false;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/validate-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<void> getUserData() async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Token no encontrado');
  }

  final response = await http.get(
    Uri.parse('$baseUrl/user'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    updateUser(
      data['id'],
      data['name'],
      data['email'],
      data['friendCode'],
      data['photo'],
      data['adrenacoins'],
      data['xp'],
      data['level'],
      data['puntosClasificacion'],
      (data['logros'] as List).map((logro) => Logro.fromJson(logro)).toList(),
      (data['partidas'] as List).map((partida) => Partida.fromJson(partida)).toList(),
    );
  } else {
    throw Exception('Error al obtener los datos del usuario');
  }
}

//Obtener del backend las cartas del sobre
Future<List<PlayerCard>?> getSobre() async {
  return [
    PlayerCard(
      playerName: 'Lionel',
      playerSurname: 'Messi',
      team : 'Paris Saint-Germain',
      shot: 95,
      control: 98,
      defense: 40,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxury,
      averageScore: 97.5,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Cristiano',
      playerSurname: 'Ronaldo',
      team : 'Juventus',
      shot: 94,
      control: 90,
      defense: 35,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxury,
      averageScore: 95.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Neymar',
      playerSurname: 'Jr.',
      team: "Paris Saint-Germain",
      shot: 92,
      control: 95,
      defense: 30,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxury,
      averageScore: 94.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Kylian',
      playerSurname: 'Mbappe',
      team : "Paris Saint-Germain",
      shot: 93,
      control: 92,
      defense: 35,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxury,
      averageScore: 94.5,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Luka',
      playerSurname: 'Modric',
      team: "Real Madrid",
      shot: 85,
      control: 95,
      defense: 80,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.megaLuxury,
      averageScore: 90.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Medio',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Sergio',
      playerSurname: 'Ramos',
      team: "Real Madrid",
      shot: 70,
      control: 85,
      defense: 95,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.normal,
      averageScore: 90.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Virgil',
      playerSurname: 'van Dijk',
      team: "Liverpool",
      shot: 60,
      control: 80,
      defense: 95,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxuryXI,
      averageScore: 88.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Delantero',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Kevin',
      playerSurname: 'De Bruyne',
      team: "Manchester City",
      shot: 85,
      control: 95,
      defense: 75,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxuryXI,
      averageScore: 92.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Robert',
      playerSurname: 'Lewandowski',
      team :  "Bayern Munich",
      shot: 95,
      control: 90,
      defense: 40,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.normal,
      averageScore: 93.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Medio',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Manuel',
      playerSurname: 'Neuer',
      team : "Bayern Munich",
      shot: 50,
      control: 85,
      defense: 95,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxury,
      averageScore: 90.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Delantero',
      price : 20.0,
    ),
  ];
}

Future<List<Map<String, dynamic>>> getFriends() async {
  final token = await getToken();
  if (token == null) throw Exception('Token no encontrado');

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user/friends'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['friends'] as List<dynamic>).cast<Map<String, dynamic>>();
    }
    
    return getMockFriends();
  } catch (e) {
    if (kDebugMode) return getMockFriends();
    rethrow;
  }
}

Future<Map<String, dynamic>> getFriendDetails(int id) async {
  final token = await getToken();
  if (token == null) throw Exception('Token no encontrado');

  final response = await http.get(
    Uri.parse('$baseUrl/friends/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return {
      'nivel': data['nivel'] as int,
      'xp': data['xp'] as int,
      'logros': (data['logros'] as List<dynamic>)
          .map((logro) => Logro.fromJson(logro))
          .toList(),
    };
  } else {
    throw Exception('Error al obtener detalles: ${response.statusCode}');
  }
}

List<Map<String, dynamic>> getMockFriends() {
  return [
    {
      'id': 1,
      'name': 'Lionel Messi',
      'photo': '',
    },
    {
      'id': 2,
      'name': 'Cristiano Ronaldo',
      'photo': '',
    },
    {
      'id': 3,
      'name': 'Neymar Jr',
      'photo': '',
    },
  ];
}