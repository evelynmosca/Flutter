import 'package:flutter/material.dart';

class Telacolumn extends StatelessWidget {
  const Telacolumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Tela Column", style:TextStyle(color: Colors.white)
      ),
      backgroundColor: Colors.black,
      centerTitle: true,
      ),
      body: Center(child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 25,
        children: [
        Container(width: 20, height: 20, color:Colors.blue),
        Container(width: 40, height: 40, color: Colors.pink),
        Container(width: 60, height: 60, color: Colors.purple),
        TextButton(onPressed: (){
          Navigator.pushNamed(context, "/row");
        }, child: Text("Clique aqui -> Row"))
      ],))
    );
  }
}