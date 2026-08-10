import 'package:flutter/material.dart';

class Telamix extends StatelessWidget {
  const Telamix({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Tela Mix", style:TextStyle(color: Colors.white)
      ),
      backgroundColor: Colors.black,
      centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Olá Mundo", style: TextStyle(fontFamily: "dimond"),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(width: 60, height: 60, color:Colors.blue),
          Container(width: 60, height: 60, color: Colors.pink),
          Container(width: 60, height: 60, color: Colors.purple),
          ],
        ),
          Container(width: 60, height: 60, color:Colors.blue),
          Container(width: 60, height: 60, color: Colors.pink),
          Image.asset("assets/florzinha.jpg", width: 60, height: 60),
        Stack(
          alignment: Alignment.center,
          children: [
          ],
        ),
        TextButton(onPressed: (){
          Navigator.pushNamed(context, "/");
        }, child: Text("Clique aqui -> Column")),
      ],));
  }
}

// colcoar imagem da internet, Image.network("url", width: x, height: y) nem todas funcionam
// colocar imagem, cria a pasra assets, coloca a imagem baixada, depois substitua container por
// Image.asset("/assets/nomedafoto.png") tem que ser png