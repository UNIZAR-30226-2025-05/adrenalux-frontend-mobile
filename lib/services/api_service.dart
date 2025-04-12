import 'dart:convert';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/plantilla.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://adrenalux.duckdns.org/api/v1';

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
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
  
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['data']['token']);
        return data;
      } else {
        return {
          ...data,
          'error' : jsonDecode(response.body)['status']['error_message'] ?? 'Error desconocido',
        }; 
      }
    } else {
      print("Error: ${response.body}");
      return {
        'error' : jsonDecode(response.body)['status']['error_message'] ?? 'Error desconocido',
      }; 
    }
  }

  Future<Map<String, dynamic>> signInWithGoogleAPI(String tokenId) async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tokenId': tokenId }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['data']['token']);
        return data;
      } else {
        throw Exception(jsonDecode(response.body)['error']);
      }
  }

  Future<bool> signOut() async {
    final token = await getToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/sign-out'),
      headers: {
        'Content-Type': 'application/json', 
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
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

    if(data == null) {return;}

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
    
    int id = data['id'] is int 
    ? data['id'] 
    : int.tryParse(data['id'].toString()) ?? 0;

    updateUser(
      id,
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
      data['plantilla_activa_id'],
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



  Future<Map<String, dynamic>> getSobre(Sobre? sobre) async {
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
            List<Logro> logrosList = [];
            final logrosJson = responseJson['logros'];

            List<PlayerCard> cartas = cartasJson
                .map((c) => PlayerCard.fromJson(c))
                .toList();

            if (logrosJson != null && logrosJson is List && logrosJson.isNotEmpty) {
              logrosList = logrosJson.map((item) => Logro.fromJson(item)).toList();
            }

            if(logrosList.isNotEmpty){
              updateLogros(logrosList);
            }      
            
            updateExperience(responseJson['XP'], responseJson['xpMax']); 
            updateLvl(responseJson['nivel'] ?? 1);  

            return {'cartas': cartas, 'logroActualizado': logrosList.isNotEmpty};
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
    return 'https://adrenalux.duckdns.org${path.startsWith('/') ? path : '/$path'}';
  }

  //Obtener del backend las cartas del sobre
  Future<List<Sobre>?> getSobresDisponibles() async {
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

  Future<List<PlayerCard>> getCollection() async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coleccion/getColeccion'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
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

  Future<bool> sellCard(cartaId, precio) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mercado/mercadoCartas/venderCarta'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', 
        },
        body: jsonEncode({
          'cartaId': cartaId,
          'precio': precio, 
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 400) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return responseData['success'];
      }

      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PlayerCard>> getMarket() async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mercado/mercadoCartas/obtenerCartasMercado'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          
          return data.map((card) => PlayerCard.fromJson(card)).toList();
        } else {
          throw Exception('Error en la respuesta del servidor: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Error al obtener las cartas: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PlayerCard>> getDailyLuxuries() async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mercado/mercadoDiario/obtenerCartasEspeciales'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((card) => PlayerCard.fromJson(card)).toList();
        } else {
          throw Exception('Error en la respuesta del servidor: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Error al obtener las cartas diarias: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> purchaseDailyCard(int? mercadoDiarioId) async {

    if(mercadoDiarioId == null) {return;}

    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final response = await http.post(
      Uri.parse('$baseUrl/mercado/mercadoDiario/comprarCartaEspecial/$mercadoDiarioId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> purchaseMarketCard(int? mercadoCartaId) async {
    if(mercadoCartaId == null) {return;}

    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final response = await http.post(
      Uri.parse('$baseUrl/mercado/mercadoCartas/comprarCarta/$mercadoCartaId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<bool> deleteFromMarket(int? cardId) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/mercado/mercadoCartas/retirarCarta/$cardId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard(bool isGlobal) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final url = isGlobal
        ? '$baseUrl/clasificacion/total'
        : '$baseUrl/clasificacion/amigos';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> leaderboardList = [];
      
      if (data is List) {
        leaderboardList = data;
      } else if (data['data'] != null && data['data'] is List) {
        leaderboardList = data['data'];
      } else if (!isGlobal && data['user'] != null) {
        if (data['user'] is List) {
          leaderboardList = data['user'];
        } else {
          leaderboardList = [data['user']];
        }
      }

      return leaderboardList
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } else {
      if (kDebugMode) {
        return getMockLaderboard(isGlobal);
      }
      return [];
    }
  }


  /*
  * Llamadas al backend relacionadas con la funcionalidad social
  * 
  */

  Future<List<Map<String, dynamic>>> getFriends() async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/friends'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final friendsList = (data['data'] as List<dynamic>?) ?? [];
        return friendsList.map<Map<String, dynamic>>((item) {
          if (item is Map<String, dynamic>) {
            return {
              'id': item['id']?.toString() ?? '',
              'friend_code' : item['friend_code'],
              'username': item['username']?.toString().trim() ?? '', 
              'avatar': item['avatar']?.toString() ?? 'assets/default_profile',
              'name': item['name']?.toString() ?? '',
              'lastname': item['lastname']?.toString() ?? '',
              'level': (item['level'] as int?) ?? 0,
              'isConnected': item['isConnected'], 
            };
          }
          return {};
        }).where((item) => item.isNotEmpty).toList();
      }

      throw Exception('Error ${response.statusCode}: ${(data['status']?['error_message']) ?? 'Error desconocido'}');

    } catch (e) {
      print("Error en getFriends: $e");
      if (kDebugMode) {
        return getMockFriends();
      }
      rethrow;
    }
  }

  Future<bool> sendFriendRequest(String friendCode) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/friends/request'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'friendCode': friendCode}),
      );

      final data = jsonDecode(response.body);

      return data['data']['success'] ?? false;

    } on http.ClientException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } on FormatException {
      throw Exception('Error procesando la respuesta del servidor');
    } catch (e) {
      throw Exception('Error enviando solicitud: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/friends/requests'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return (data['data'] as List<dynamic>).map((request) {
          return {
            'id': request['id'],
            'created_at': request['created_at'],
            'sender': {
              'id': request['sender']['id'],
              'username': request['sender']['username'],
              'name': request['sender']['name'],
              'lastname': request['sender']['lastname'],
              'avatar': request['sender']['avatar'],
              'friend_code': request['sender']['friend_code'],
              'level': request['sender']['level']
            }
          };
        }).toList().cast<Map<String, dynamic>>();
      }

      if (data['message'] != null) {
        throw Exception(data['message']);
      }
      
      throw Exception('Error desconocido: ${response.statusCode}');

    } on http.ClientException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print("Error $e");
      if (kDebugMode) {
        return [
          {
            'id': '123-456',
            'created_at': DateTime.now().toIso8601String(),
            'sender': {
              'id': 123,
              'username': 'mock_user',
              'name': 'Mock',
              'lastname': 'User',
              'avatar': 'default_avatar.png',
              'friend_code': 'MOCK123',
              'level': 5
            }
          }
        ];
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFriendDetails(String id) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final response = await http.get(
      Uri.parse('$baseUrl/profile/friends/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return {
        'id' : data['id'],
        'name' : data['username'],
        'friend_code' : data['friend_code'],
        'avatar' : data['avatar'],
        'level': data['level'], 
        'xp': data['experience'].toInt() ?? 0,
        'xpMax': data['xpMax'].toInt() ?? 0, 
        'partidas': (data['partidas'] as List<dynamic>)
            .map((partida) => Partida.fromJson(partida))
            .toList(),
        'logros': (data['logros'] as List<dynamic>)
            .map((logro) => Logro.fromJson(logro))
            .toList(),
      };
    } else {
      throw Exception('Error al obtener detalles: ${response.statusCode}');
    }
  }


  Future<bool> acceptRequest(String requestId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/friends/requests/$requestId/accept'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool?> declineRequest(String requestId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/friends/requests/$requestId/decline'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      final data = jsonDecode(response.body);
      
      return data['success'] ?? false;
    } catch (e) {
      return null;
    }
  }

  Future<bool?> deleteFriend(String friendId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/profile/friends/$friendId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return null;
    }
  }

  /*
  * Llamadas al backend relacionadas con la funcionalidad de partidas
  * 
  */

  final Map<String, List<String>> _positionMapping = {
      'defender': ['DEF1', 'DEF2', 'DEF3', 'DEF4'],
      'midfielder': ['MID1', 'MID2', 'MID3'],
      'forward': ['FWD1', 'FWD2', 'FWD3'],
      'goalkeeper': ['GK'],
    };


  Future<List<Draft>?> getPlantillas() async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final plantillasResponse = await http.get(
        Uri.parse('$baseUrl/plantillas'),
        headers: {'Authorization': 'Bearer $token'},
      );


      if (plantillasResponse.statusCode != 200) {
        throw Exception('Error obteniendo plantillas: ${plantillasResponse.body}');
      }

      final responseBody = jsonDecode(plantillasResponse.body);

      final plantillasData = (responseBody['data'] as List?) ?? [];

      if (plantillasData.isEmpty) {
        print("No hay plantillas disponibles.");
        return [];
      }
      
      List<Draft> plantillas = [];
      
      for (var p in plantillasData) {
        final cartasResponse = await http.get(
          Uri.parse('$baseUrl/plantillas/getCartasporPlantilla/${p['id']}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        );
        
        if (cartasResponse.statusCode != 200) continue;

        final cartasData = (jsonDecode(cartasResponse.body)['data'] as List?) ?? [];

        Map<String, List<PlayerCard>> cartasPorPosicion = {};
        for (var carta in cartasData) {
          final pos = carta['posicion'].toLowerCase();
    
          cartasPorPosicion.putIfAbsent(pos, () => []);
          if (carta['id'] != null && carta['nombre'] != null) {
            cartasPorPosicion[pos]!.add(PlayerCard.fromJson(carta));
          }
        }


        Map<String, PlayerCard> cartasPlantilla = {};
        cartasPorPosicion.forEach((posicion, listaCartas) {
          final slots = _positionMapping[posicion];
          if (slots != null) {
            for (int i = 0; i < listaCartas.length && i < slots.length; i++) {
              cartasPlantilla[slots[i]] = listaCartas[i];
            }
          } else {
            print("No hay slots definidos para la posición $posicion");
          }
        });

        
        plantillas.add(Draft(
          id: p['id'],
          name: p['nombre'] as String,
          draft: cartasPlantilla,
        ));
      }

      return plantillas;

    } catch (e) {
      print("Error en getPlantillas: $e");
      return null;
    }
  }

  
  Future<List<Partida>> getPartidasPausadas() async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.get(
          Uri.parse('$baseUrl/partidas/pausadas'),
          headers: {'Authorization': 'Bearer $token'},
        );

      final responseBody = jsonDecode(response.body);


      if (response.statusCode == 200) {
        final List<dynamic> data = responseBody['data']['pausedMatches'] as List? ?? [];
        return data.map((json) => Partida.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error en getPartidasPausadas: $e");
      return [];
    }
  }
Future<bool> createPlantilla(Draft plantilla) async {
    final token = await getToken();
    final String id;
    if (token == null) throw Exception('Token no encontrado');

    try {

      if(plantilla.id == null) {
        final plantillasResponse = await http.post(
          Uri.parse('$baseUrl/plantillas'),
          headers: {'Authorization': 'Bearer $token'},
          body : {'nombre' : plantilla.name},
        );

        final responseBody = jsonDecode(plantillasResponse.body);

        id = responseBody['plantilla']['id'].toString();
      } else {
        id = plantilla.id.toString();
      }
      

      List<int> cartasIds = [];
      List<String> posiciones = [];
      
      plantilla.draft.forEach((templatePos, player) {
        if (player != null) {
          cartasIds.add(player.id);
          posiciones.add(player.position);
        }
      });

      final insercionCartas = await http.post(
        Uri.parse('$baseUrl/plantillas/agregarCartasPlantilla'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body : jsonEncode({ 
          'plantillaId': id,
          'cartasid': cartasIds, 
          'posiciones': posiciones,
        }),
      );

      if(insercionCartas.statusCode == 200) {
        saveDraftTemplate(id, plantilla.name, plantilla.draft);
        activarPlantilla(id);
        return true;
      }

      print("Error al insertar cartas, codigo: ${insercionCartas.statusCode}");
      return false;
    } catch (e) {
      print("Error en crear plantilla: $e");
      return false;
    }
  }

  Future<bool> activarPlantilla(id) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/plantillas/activarPlantilla'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body : jsonEncode({ 'plantillaId': id}),
      );

      if(response.statusCode == 200) {
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }

  Future<bool> deletePlantilla(id) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/plantillas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body : jsonEncode({ 'plantillaIdNum': id}),
      );

      if(response.statusCode == 200) {
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getActiveTournaments() async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/torneos/getTorneosActivos'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }
      throw Exception('Error ${response.statusCode}: ${response.body}');
    } catch (e) {
      throw Exception('Error obteniendo torneos: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserTournaments() async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/torneos/getTorneosJugador'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Torneos: $data");
        return List<Map<String, dynamic>>.from(data['data']);
      }
      throw Exception('Error ${response.statusCode}: ${response.body}');
    } catch (e) {
      throw Exception('Error obteniendo torneos: $e');
    }
  }

  Future<Map<String, dynamic>> createTournament(
    String name, 
    String? password,
    String prize,
    String description
  ) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/torneos/crear'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'nombre': name,
          'contrasena': password,
          'premio': prize,
          'descripcion': description,
        }),
      );

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return responseBody['data'];
      }
      
      final errorMessage = responseBody['error'] ?? 'Error desconocido';
      throw Exception(errorMessage);

    } on http.ClientException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  Future<void> joinTournament(String tournamentId, String? password) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/torneos/unirse'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'torneo_id': tournamentId,
          'contrasena': password
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['error']);
      }
    } catch (e) {
      throw Exception('Error uniéndose al torneo: $e');
    }
  }

  Future<bool> abandonTournament(String tournamentId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/torneos/abandonarTorneo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'torneo_id': tournamentId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['error']);
      }
      return true;
    } catch (e) {
      throw Exception('Error uniéndose al torneo: $e');
    }
  }

  Future<Map<String, dynamic>> getTournamentDetails(String tournamentId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/torneos/getTorneo/$tournamentId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      throw Exception('Error ${response.statusCode}: ${response.body}');
    } catch (e) {
      throw Exception('Error obteniendo detalles: $e');
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
        'avatar': '',
      },
      {
        'id': 2,
        'name': 'Cristiano Ronaldo',
        'avatar': '',
      },
      {
        'id': 3,
        'name': 'Neymar Jr',
        'avatar': '',
      },
    ];
  }
}