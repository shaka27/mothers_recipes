import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mothers_recipes/provider/favourite_Provider.dart';
import 'package:mothers_recipes/provider/quantity_provider.dart';
import 'package:mothers_recipes/views/appMain.dart';
import 'package:provider/provider.dart';
import 'package:mothers_recipes/widgets/auth_gate.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavouriteProvider()),
        ChangeNotifierProvider(create: (_) => QuantityProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
      ),
    );
  }
}


