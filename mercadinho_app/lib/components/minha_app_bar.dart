import 'package:flutter/material.dart';

class MinhaAppBar extends StatelessWidget implements PreferredSizeWidget{
  const MinhaAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
        const Text("Mercadinho", style: TextStyle(fontWeight: FontWeight.bold)),
        IconButton(onPressed: ()=> Navigator.pushNamed(context, "/gestao"), icon: Icon(Icons.settings))
      ],),
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xff4b27b8),
    );
  }

  @override 
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}
