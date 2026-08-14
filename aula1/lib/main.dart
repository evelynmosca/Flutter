import 'package:aula1/navigation/navbar.dart';
import 'package:aula1/pages/telacolumn.dart';
import 'package:aula1/pages/telamix.dart';
import 'package:aula1/pages/telarow.dart';
import 'package:aula1/pages/telastack.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() { // função principal
  runApp(const MyApp()); // função que roda o app 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // forncece os componentes para as telas e faz a configuração geral do app
    initialRoute: "/",
    routes: {
      "/":(context) => Navbar(),
      "/column":(context) => Telacolumn(),
      "/row":(context) => Telarow(),
      "/stack":(context) => Telastack(),
      "/mix":(context) => Telamix()
    },
    theme: ThemeData(fontFamily: GoogleFonts.poppins().fontFamily),
    );
  }
}