import 'package:flutter/material.dart';

class ImagemLogo extends StatelessWidget {
  const ImagemLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.network("https://static.wikia.nocookie.net/youtv/images/5/54/Netflix_logo.png/revision/latest?cb=20180527192151", 
    width: 100);
  }
}