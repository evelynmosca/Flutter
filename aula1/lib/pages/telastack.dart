import 'package:flutter/material.dart';

class Telastack extends StatelessWidget {
  const Telastack({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tela Stack", style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      centerTitle: true,
      ),
      body: Center(child: Stack(
        alignment: Alignment.center,
        children: [
        Container(width: 60, height: 60, color:Colors.blue),
        Container(width: 40, height: 40, color: Colors.pink),
        Container(width: 20, height: 20, color: Colors.purple),
        TextButton(onPressed: (){
          Navigator.pushNamed(context, "/mix");
        }, child: Text("Clique aqui -> Mix")),
      ],))
    );
  }
}