import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // aqui vc coda a lógica
  @override
  void initState(){
  super.initState();
  Future.delayed( // função futura que espera um determinado tempo depois realiza uma ação
    Duration(seconds: 5),
    (){Navigator.pushNamed(context,"/home");}
  );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
        Image.network("https://static.vecteezy.com/ti/vetor-gratis/p1/4492842-ilustracao-em-desenho-animado-supermercado-cesta-icone-cheio-de-produtos-e-vegetais-vetor.jpg", width: 200),
        CircularProgressIndicator(color: Colors.orange,)
      ]))
    );
  }
}