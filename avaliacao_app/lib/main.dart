import 'package:flutter/material.dart';

import 'screens/configuracoes_screen.dart';
import 'screens/gerenciamento_screen.dart';
import 'screens/home_screen.dart';
import 'screens/produtos_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const roxo = Color(0xFF4B27B8);
    return MaterialApp(
      title: 'Mercadinho Genciana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: roxo),
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: roxo,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/produtos': (context) => const ProdutosScreen(),
        '/gerenciamento': (context) => const GerenciamentoScreen(),
        '/configuracoes': (context) => const ConfiguracoesScreen(),
      },
    );
  }
}
