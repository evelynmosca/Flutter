import 'package:flutter/material.dart';
import 'package:portifolio/styles/geral.dart';

class TelaDinamica extends StatefulWidget {
  const TelaDinamica({super.key});

  @override
  State<TelaDinamica> createState() => _TelaDinamicaState();
}

class _TelaDinamicaState extends State<TelaDinamica> {
  int indexFrase = 0;

  List frases = [
    "there is a freedom waiting for you, on the sky, and you ask,\nwhat if I fall? But darling, what if you fly?",
    "cuidado para não achar que benção é somente financeira",
    "a vida fica mais leve depois que você entende\nque nem tudo precisa de reação, é só deixar pra lá e viver em paz",
    "você pode ser gentil e impor seus limites",
    "às vezes tem um oceano te esperando\ne você nadando nessa poça de água",
    "não existe isso de no fundo é uma boa pessoa, não estamos\nprocurando petróleo, a bondade deve ser vista na superfície",
    "a raiva assusta, porque é o momento em que paramos de\ndefender os outros e começamos a nos defender dos outros"
  ];

  void mudarFrase() {
    if (indexFrase < frases.length - 1) {
      setState(() {
        indexFrase++;
      });
    } else {
      setState(() {
        indexFrase = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: AppBar(
        title: Text("Meu Portifólio"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(
            children: [

              Text(
                "Veja alguns dos meus projetos",
                style: texto,
              ),

              SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    width: 320,
                    padding: EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            "assets/e-learn.png",
                            width: 250,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(height: 20),

                        Text(
                          "E-learn",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Projeto de TCC desenvolvido para ser uma plataforma de estudo e controle de conteúdo para instrutores e aprendizes.",
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 15),

                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.favorite_border,
                            color: Colors.deepPurple,
                          ),
                          label: Text(
                            "Curtir",
                            style: TextStyle(
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 40),

                  Container(
                    width: 320,
                    padding: EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            "assets/evm.png",
                            width: 250,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(height: 20),

                        Text(
                          "EVM",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Projeto de Hackathon desenvolvido para ser um gerenciador de férias dos colaboradores.",
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 15),

                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.favorite_border,
                            color: Colors.deepPurple,
                          ),
                          label: Text(
                            "Curtir",
                            style: TextStyle(
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    width: 320,
                    padding: EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            "assets/tpm calendar.png",
                            width: 250,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(height: 20),

                        Text(
                          "TPM Calendar",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Projeto de área desenvolvido para ser um sistema de controle de eventos.",
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 15),

                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.favorite_border,
                            color: Colors.deepPurple,
                          ),
                          label: Text(
                            "Curtir",
                            style: TextStyle(
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 40),

                  Container(
                    width: 320,
                    padding: EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            "assets/workdays.png",
                            width: 250,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(height: 20),

                        Text(
                          "WorkDays",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Projeto de Hackathon em Outsystems desenvolvido para ser um gerenciador de metas de presença empresarial.",
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 15),

                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.favorite_border,
                            color: Colors.deepPurple,
                          ),
                          label: Text(
                            "Curtir",
                            style: TextStyle(
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 70),

              Text(
                "Frases que gosto de ler e podem te dar uma outra perspectiva.",
                style: texto,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30),

              Container(
                width: 700,
                padding: EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    Icon(
                      Icons.format_quote,
                      size: 40,
                      color: Colors.deepPurple,
                    ),

                    SizedBox(height: 15),

                    Text(
                      frases[indexFrase],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 20),

                    TextButton(
                      onPressed: mudarFrase,

                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,

                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 15,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: Text("Próxima frase"),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}