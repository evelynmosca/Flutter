import 'package:flutter/material.dart';

class InputLogin extends StatelessWidget {
  final TextEditingController fofoqueira;
  final String placeholder;
  final TextInputType tipo;
  final bool senha;
  final IconData? icone;
  const InputLogin({super.key, required this.fofoqueira, required this.placeholder, this.tipo = TextInputType.text, this.senha = false, this.icone});

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: fofoqueira,
        keyboardType: tipo,
        obscureText: senha,
        decoration: InputDecoration(
          labelText: placeholder,
          prefixIcon: icone == null ? null : Icon(icone),
          filled: true,
          fillColor: const Color(0xfff7f7fc),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xff4b27b8), width: 2)),
        ),
    );
  }
}

//OutlineInputBorder é a borda arredondada 
//RoundedRectangleBorder é  borda retangulo
