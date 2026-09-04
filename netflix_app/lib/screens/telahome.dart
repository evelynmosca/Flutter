import 'package:flutter/material.dart';
import 'package:netflix_app/components/botaonavegar.dart';
import 'package:netflix_app/components/minhaappbar.dart';
import 'package:netflix_app/screens/teladetalhes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  // codamos a lógica aqui
  List<String> mostrarFilmes = [];

  @override
  void initState() { //função que carrega uma outra função qundo a tela abre
  super.initState();
  carregarFilmes();
  }

  // toda ves que uma função busca um dado de outra platforma use uma função aync
  void carregarFilmes() async{
    SharedPreferences banco = await SharedPreferences.getInstance();
    List<String> filmesBanco = banco.getStringList("filmes") ?? [];
    setState(() {
      mostrarFilmes = filmesBanco;
    });
  }

  void deletarFilme(String filme) async{
    SharedPreferences banco = await SharedPreferences.getInstance();
    List<String> filmesBanco = banco.getStringList("filmes") ?? [];
    filmesBanco.remove(filme);
    await banco.setStringList("filmes", filmesBanco);
    setState(() {
      mostrarFilmes = filmesBanco;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinhaAppBar(),
      body:mostrarFilmes.isEmpty ? Center(child: Text("Não tem filmes")) : 
      GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        children: [
          for(String filme in mostrarFilmes)
          Column(children: [
            GestureDetector(onTap:() => Navigator.push(context,MaterialPageRoute(builder: (context) => TelaDetalhes(filme: filme))),
            child: Image.network(filme.split("|")[3], width: 100,),
            ),
            Text(filme.split("|")[0]),
            BotaoNavegar(funcao: ()=> deletarFilme(filme), textobotao: "Deletar",)
          ],)
        ],
      )
    );
  }
}