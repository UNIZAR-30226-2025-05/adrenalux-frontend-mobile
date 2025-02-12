import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
    body: jsonEncode({'email': email, 'password': password}),
  );
  final data = jsonDecode(response.body);

  signIn(email, password);

  return data;
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

  /* Redirigir al usuario a la pantalla de inicio de sesión
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SignInScreen()),
  );
  */
}


Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); 
}

Future<bool> validateToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  print('token $token');
  if (token == null) {
    return false;
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/validate-token'),
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
