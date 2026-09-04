import 'package:contador_app/screens/telacontador.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// classe mãe
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/":(context) => Telacontador()
    },
    );
  }
}