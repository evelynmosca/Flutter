// estilo do texto
// estilo de componente usamos final e estilo de cor usamos const

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final titulo = TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.bold,
  color: Colors.pink,
  fontFamily: GoogleFonts.poppins().fontFamily
);

final botao = TextButton.styleFrom(
  backgroundColor: Colors.pink,
  foregroundColor: Colors.white,
  fixedSize: Size(40, 20)
);

