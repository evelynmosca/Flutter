import 'package:aula1/pages/telacolumn.dart';
import 'package:aula1/pages/telamix.dart';
import 'package:aula1/pages/telarow.dart';
import 'package:aula1/pages/telastack.dart';
import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  //aqui vc coda sua lógica
  int index = 0;

  List telas = [
    Telacolumn(),
    Telarow(),
    Telastack(),
    Telamix()
  ];

  void mudarIndex(int indexNovo){
    setState(() {
      index = indexNovo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: telas.elementAt(index),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.view_agenda), label: "Column"),
        BottomNavigationBarItem(icon: Icon(Icons.view_column), label: "Row"),
        BottomNavigationBarItem(icon: Icon(Icons.layers), label: "Stack"),
        BottomNavigationBarItem(icon: Icon(Icons.widgets), label: "Mix"),
      ],
      currentIndex: index, //fala qual é o index atual para abrir a página
      onTap: mudarIndex,
      type: BottomNavigationBarType.fixed //tira o aviso de limite de botões
      ),

    );
  }
}