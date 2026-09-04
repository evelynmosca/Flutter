import 'package:flutter/material.dart';
import 'package:netflix_app/components/botaonavegar.dart';
import 'package:netflix_app/components/imagemlogo.dart';
import 'package:netflix_app/components/meutextfield.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  // aqui fica a lógica interna da tela
  String email = "evelyn@gmail.com";
  String senha = "123";

  // variável que observa o que o usuário está digitando
  TextEditingController emailDigitado = TextEditingController();
  TextEditingController senhaDigitada = TextEditingController();

  void logar(){
  if(emailDigitado.text == email && senhaDigitada.text == senha){
    Navigator.pushNamed(context, "/home");
  }else{
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Credenciais inválidas! Tente novamente."))
    );
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: double.infinity, height: double.infinity, color: Colors.black),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 30,
            children: [
            ImagemLogo(),
            MeuTextField(controlador: emailDigitado, tipo: "email"),
            MeuTextField(controlador: senhaDigitada, tipo: "senha"),
            BotaoNavegar(funcao: logar, textobotao: "Login")
          ],)
        ],
      ),
    );
  }
}