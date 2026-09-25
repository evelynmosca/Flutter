import 'package:flutter/material.dart';
import 'package:mercadinho_app/navigation/navbar.dart';
import 'package:mercadinho_app/screens/splascreen.dart';
import 'package:mercadinho_app/screens/telagestao.dart';
import 'package:mercadinho_app/screens/telahome.dart';
import 'package:mercadinho_app/screens/telalogin.dart';
import 'package:mercadinho_app/screens/telaperfil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff4b27b8), primary: const Color(0xff4b27b8), secondary: const Color(0xff1976d2)),
        scaffoldBackgroundColor: const Color(0xfff7f7fc),
        appBarTheme: const AppBarTheme(foregroundColor: Colors.white, backgroundColor: Color(0xff4b27b8), elevation: 0),
        cardTheme: CardThemeData(color: Colors.white, surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes:{
        "/":(context) => SplashScreen(),
        "/home":(context)=> TelaHome(),
        "/perfil":(context)=> TelaPerfil(),
        "/navbar":(context)=> NavBar(),
        "/login":(context)=> TelaLogin()
      },
      onGenerateRoute: (settings) {
        if(settings.name == "/gestao"){
          if(statusAdmin != null && statusAdmin == true){
            return MaterialPageRoute(builder: (context)=> TelaGestao());
          }else{
            return MaterialPageRoute(builder: (context)=> NavBar()); 
          }
        }
      },
    );
  }
}
