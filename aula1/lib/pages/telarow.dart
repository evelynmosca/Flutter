import 'package:flutter/material.dart';

class Telarow extends StatelessWidget {
  const Telarow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Tela Row", style: TextStyle(color: Colors.black)
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      ),
      body: Center(child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 25,
        children: [
        Container(width: 20, height: 20, color:Colors.blue),
        Container(width: 40, height: 40, color: Colors.pink),
        Container(width: 60, height: 60, color: Colors.purple),
        TextButton(onPressed: (){
          Navigator.pushNamed(context, "/stack");
        }, child: Text("Clique aqui -> Stack")),
      ],)),
    );
  }
}