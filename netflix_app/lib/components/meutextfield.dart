import 'package:flutter/material.dart';

class MeuTextField extends StatelessWidget {
  TextEditingController controlador;
  String tipo;
  MeuTextField({super.key, required this.controlador, required this.tipo});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 200),child: 
    TextField(
      controller: controlador,
      decoration: InputDecoration(
        hintText: "Digite $tipo",
        filled: true, // ativa o background do textfield
        fillColor: Colors.white,
      ),
    )
    );
  }
}
// padding para todos os lados EdgeInsets.all(x)
// padding somente nas laterais 