import 'dart:convert';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adrenalux_frontend_mobile/screens/auth/sign_in_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

final String baseUrl = 'http://54.37.50.18:3000/api/v1';

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

Future<Map<String, dynamic>> signUp(String name, String lastname, String username, String email, String password, String password2) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/sign-up'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'name': name, 'lastname': lastname, 'email': email, 'password': password}),
  );
  final responseBody = jsonDecode(response.body);

  if (response.statusCode == 201) {
    return {
      'statusCode': response.statusCode,
      'data': responseBody, 
    };
  } else {
    String errorMessage = responseBody['status']['error_message'] ?? 'Error desconocido';

    return {
      'statusCode': response.statusCode,
      'errorMessage': errorMessage, 
    };
  }
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
  final token = await getToken();
  
  final response = await http.post(
    Uri.parse('$baseUrl/auth/sign-out'),
    headers: {
      'Content-Type': 'application/json', 
      'Authorization': 'Bearer $token'
    },
  );

  if (response.statusCode == 200) {
    await prefs.remove('token'); 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }
}


Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); 
}

Future<bool> validateToken() async {
  final token = await getToken();

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
    Uri.parse('$baseUrl/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final body = jsonDecode(response.body);
  final data = body['data'];

  print("Data $data");
  List<Logro> logrosList = [];
  final logrosJson = data['logros'];
  if (logrosJson != null && (logrosJson as List).isNotEmpty) {
    logrosList = (logrosJson).map((item) {
      final logroData = item['logro'];
      return Logro.fromJson(logroData);
    }).toList();
  }

  List<Partida> partidasList = [];
  if (data['partidas'] != null && (data['partidas'] as List).isNotEmpty) {
    partidasList = (data['partidas'] as List).map((partida) => Partida.fromJson(partida)).toList();
  }
  
  DateTime? dateTime;
  if (data['ultimo_sobre_gratis'] != null) {
    dateTime = DateTime.parse(data['ultimo_sobre_gratis'].toString());
  }
  

  updateUser(
    data['id'],
    data['username'],
    data['email'],
    data['friend_code'],
    data['avatar'],
    data['adrenacoins'],
    data['experience'].round(),
    data['xpMax'].round(),
    data['level'],
    data['puntosClasificacion'],
    dateTime,
    logrosList,
    partidasList,
  );
}

Future<bool> updateUserData(String? imageUrl, String? name) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Token no encontrado');
  }

  final Map<String, dynamic> bodyData = {};
  if (imageUrl != null) {
    bodyData['avatar'] = imageUrl;
  }
  if (name != null) {
    bodyData['username'] = name;
  }

  final response = await http.put(
    Uri.parse('$baseUrl/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(bodyData),
  );

  if (response.statusCode == 200) {
    updateProfileInfo(name: name, photo: imageUrl);
    return true;
  }else {
    return false;
  }
}



Future<List<PlayerCard>?> getSobre(Sobre? sobre) async {
  String url;

  final token = await getToken();
  if (token == null) throw Exception('Token no encontrado');

  try {

    if (sobre == null) {
      url = '$baseUrl/cartas/abrirSobreRandom';
    } else {
      url = '$baseUrl/cartas/abrirSobre/${sobre.tipo}';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['data'] != null && data['data']['responseJson'] != null) {
        final responseJson = data['data']['responseJson'];
        
        if (responseJson['cartas'] != null && responseJson['cartas'] is List) {
          List<dynamic> cartasJson = responseJson['cartas'];
          cartasJson.forEach((carta) =>print("Tipo carta: ${carta['tipo_carta']}"));
          List<PlayerCard> cartas = cartasJson
              .map((c) => PlayerCard.fromJson(c))
              .toList();
          updateExperience(responseJson['XP'], responseJson['xpMax']); 
          updateLvl(responseJson['nivel'] ?? 1);  

          return cartas;
        } else {
          throw Exception('Las cartas no están disponibles o están mal formateadas.');
        }
      } else {
        throw Exception('No se encontró el objeto responseJson en los datos de respuesta.');
      }
    } else {
      throw Exception('Error al obtener las cartas: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error al obtener las cartas: $e');
  }
}

String getFullImageUrl(String path) {
  if (path.startsWith('http')) return path;
  return 'http://54.37.50.18:3000${path.startsWith('/') ? path : '/$path'}';
}

//Obtener del backend las cartas del sobre
Future<List<Sobre>> getSobresDisponibles() async {
  final token = await getToken();
  if (token == null) throw Exception('Token no encontrado');

  try {
    
    final response = await http.get(
      Uri.parse('$baseUrl/cartas/sobres'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(Duration(seconds: 15));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Sobre.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los sobres: ${response.statusCode}');
    }

  } catch (e) {
    throw Exception('Error al obtener los sobres $e');
  }
}

Future<List<Map<String, dynamic>>> getFriends() async {
  final token = await getToken();
  if (token == null) throw Exception('Token no encontrado');

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/friends'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Datos $data");
      return (data['friends'] as List<dynamic>).cast<Map<String, dynamic>>();
    }
    
    return getMockFriends();
  } catch (e) {
    if (kDebugMode) return getMockFriends();
    rethrow;
  }
}

Future<List<PlayerCard>> getCollection() async {
  final token = await getToken();
  if (token == null) throw Exception('Token no encontrado');

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/coleccion/getColeccion'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(Duration(seconds: 15));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      final List<dynamic> data = responseData['data'];

      List<PlayerCard> collection = [];

      for (var value in data) {
        collection.add(PlayerCard.fromJson(value));
      }
      return collection;
    } else {
      throw Exception('Error al obtener la colección: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}



/*
  Future<List<PlayerCard>> getMarket() async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/market'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: 15));

      //Tratamiento de los datos recibidos.
      return getMockCollection();
    } catch (e) {
      rethrow;
    }
  }
*/

Future<List<Map<String, dynamic>>> getFriendRequests() async {
  final token = await getToken();
  if (token == null) throw Exception('Token no encontrado');

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/friend-requests'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['requests'] as List<dynamic>).cast<Map<String, dynamic>>();
    }
    
    return [];
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

  Future<List<Map<String, dynamic>>> fetchLeaderboard(bool isGlobal) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final url = isGlobal
        ? '$baseUrl/leaderboard/global'
        : '$baseUrl/leaderboard/friends';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      if(kDebugMode){
        return getMockLaderboard(isGlobal);
      }
      return [];
    }
  }


/*
 * Mock methods: Se obtienen datos de prueba en etapas tempranas de desarrollo
 * 
 * 
*/

List<Map<String, dynamic>> getMockLaderboard(bool isGlobal) {
  if (isGlobal) {
    return [
      {'name': 'Jugador Global 1', 'score': 1000},
      {'name': 'Jugador Global 2', 'score': 950},
      {'name': 'Jugador Global 3', 'score': 900},
      {'name': 'Jugador Global 4', 'score': 850},
      {'name': 'Jugador Global 5', 'score': 800},
    ];
  } else {
    return [
      {'name': 'Amigo 1', 'score': 800},
      {'name': 'Amigo 2', 'score': 750},
      {'name': 'Amigo 3', 'score': 700},
      {'name': 'Amigo 4', 'score': 650},
      {'name': 'Amigo 5', 'score': 600},
    ];
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