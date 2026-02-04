import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mothers_recipes/widgets/auth_preferences.dart';

Future<void> signOut(BuildContext context) async {
  final method = await AuthPreferences.getMethod();

  // Sign out from Firebase
  await FirebaseAuth.instance.signOut();

  // Sign out from Google only if Google was used
  if (method == 'google') {
    await GoogleSignIn().signOut();
  }

}
