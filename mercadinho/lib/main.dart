import 'package:flutter/material.dart';
import 'package:mercadinho/navigation/navbar.dart';
import 'package:mercadinho/screens/splashscreen.dart';
import 'package:mercadinho/screens/telagestao.dart';
import 'package:mercadinho/screens/telahome.dart';
import 'package:mercadinho/screens/telaperfil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/":(context) => SplashScreen(),
        "/home":(context) => TelaHome(),
        "/perfil":(context) => TelaPerfil(),
        "/navbar":(context) => NavBar(),
        "/gestao":(context) => TelaGestao(),
      },
    );
  }
}