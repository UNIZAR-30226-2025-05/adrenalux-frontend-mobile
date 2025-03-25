import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:flutter/material.dart';

class GoogleAuthService {
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '35102613933-gqef7etfe4np9qe2vu4fla9bj1b0ch7r.apps.googleusercontent.com',
    signInOption: SignInOption.standard,
  );

  static Future<void> signInWithGoogle(BuildContext context) async {
    ApiService apiService = ApiService();
    try {
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('No se pudo obtener el token de Google');
      }


      final response = await apiService.signInWithGoogleAPI(
        googleAuth.idToken!, 
      );

      if (response['data']?['token'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      }
    } catch (e) {
      print('Error en Google Sign-In: $e');
    }
  }
}