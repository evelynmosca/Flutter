import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portifolio/styles/geral.dart';

class TelaApresentacao extends StatelessWidget {
  const TelaApresentacao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meu Portifólio")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 20,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage("assets/myfoto.png"),
              ),
              Text("🌟 Olá, seja bem vindo(a)!", style: texto),
            ],
          ),
          Text("Meu nome é Evelyn, tenho 20 anos e sou natural de Campinas-SP"),
          Text(
            "Sou uma desenvolvedora não tão convencional. Crio interfaces autênticas e que transmitem\nminha personalidade, apesar de não gostar muito de desenvolver, acredito que o bom design \né aquele que resolve de forma simples. Sou uma pessoa reservada, com poucos amigos\npróximos, simpática e divertida, apesar da cara fechada.",
          ),
          Text(
            "Caso tenha interesse, entre em contato comigo por e-mail ou acesse meu github abaixo:",
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "https://github.com/");
                },
                child: FaIcon(FontAwesomeIcons.github),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "https://mail.google.com/");
                },
                child: Icon(Icons.email),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Tecnologias que mais gosto", style: texto)],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 40,
            children: [
              Container(
                width: 150,
                height: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(87, 233, 30, 98),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [Text("Java"), FaIcon(FontAwesomeIcons.java)],
                ),
              ),
              Container(
                width: 150,
                height: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(83, 30, 33, 233),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [Text("Py"), FaIcon(FontAwesomeIcons.python)],
                ),
              ),
              Container(
                width: 150,
                height: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(85, 30, 226, 233),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [Text("React"), FaIcon(FontAwesomeIcons.react)],
                ),
              ),
              Container(
                width: 150,
                height: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(103, 233, 30, 216),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [Text("Flutter"), FaIcon(FontAwesomeIcons.flutter)],
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/dinamica");
            },
            child: Text("Clique aqui para ver alguns projetos meus"),
          ),
        ],
      ),
    );
  }
}
