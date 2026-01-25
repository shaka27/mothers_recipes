import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mothers_recipes/views/auth_screen.dart';
import 'package:mothers_recipes/views/app_HomeScreen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Waiting for Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User logged in
        if (snapshot.hasData) {
          return const MyAppHomescreen();
        }

        // Not logged in
        return const AuthScreen();
      },
    );
  }
}
