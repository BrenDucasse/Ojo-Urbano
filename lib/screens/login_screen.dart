import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
         onPressed: () async {
          final user = await _authService.signInWithGoogle();

          if (!context.mounted) return; // 🔥 CLAVE

          if (user != null) {
            print("✅ Login: ${user.email}");

            Navigator.pushReplacementNamed(context, '/home');
          } else {
            print("❌ Error en login");
          }
        },
          child: Text("Continuar con Google"),
        ),
      ),
    );
  }
}