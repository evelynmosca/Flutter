import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mercadinho/components/minha_appbar.dart';
import 'package:mercadinho/components/produtos.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  // lógica aqui
  List produtos = [];

  @override
  void initState() {
  super.initState();
  fazerGet();
  }
  void fazerGet() async{
    // final é o tipo de variável que começa nulo e depois receb um valor, ideal para comunicação com api
    final respostaServidor = await http.get(Uri.parse("https://mercadinho-api-ouaq.onrender.com/produtos"));
    if(respostaServidor.statusCode == 200){
      final dados = jsonDecode(respostaServidor.body);
      setState(() {
        produtos = dados;
      });
    }else{
      if(mounted){ // mounted verifica se a página foi montada antes de aparecer uma mensagem de falha
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Falha na API")));
      } 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinhaAppBar(),
      body: produtos.isEmpty? Center(child: Text("Carregando produtos...")):
      GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      children: [
        for(final produto in produtos)
        ProdutosCard(nome: produto["nome"], preco: produto["preco"], urlImagem: produto["imagem"])
      ],
      ) 
    );
  }
}