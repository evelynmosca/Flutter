import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mercadinho_app/components/inputlogin.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final emailDigitado = TextEditingController();
  final senhaDigitada = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool carregando = false;

  Future<void> fazerLogin() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => carregando = true);

    final resposta = await http.get(Uri.parse("https://mercadinho-api-ouaq.onrender.com/usuarios"));
    if (!mounted) return;

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);
      final usuario = dados.cast<dynamic>().firstWhere(
        (item) => item["email"] == emailDigitado.text && item["senha"] == senhaDigitada.text,
        orElse: () => null,
      );

      if (usuario != null) {
        usuarioId = usuario["id"];
        usuarioEmail = usuario["email"];
        statusAdmin = usuario["admin"];
        Navigator.pushNamed(context, "/navbar");
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("E-mail ou senha inválidos")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Não foi possível conectar ao servidor")));
    }

    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Entrar")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.shopping_basket_rounded, size: 52, color: Color(0xff4b27b8)),
                      const SizedBox(height: 12),
                      const Text("Bem-vindo!", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      InputLogin(fofoqueira: emailDigitado, placeholder: "E-mail", tipo: TextInputType.emailAddress, icone: Icons.email_outlined),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: senhaDigitada,
                        obscureText: true,
                        validator: (valor) => valor == null || valor.isEmpty ? "Digite sua senha" : null,
                        decoration: InputDecoration(
                          labelText: "Senha",
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: const Color(0xfff7f7fc),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xff4b27b8), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: carregando ? null : fazerLogin,
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                        child: carregando ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("Entrar"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

dynamic usuarioId;
dynamic usuarioEmail;
bool? statusAdmin;
