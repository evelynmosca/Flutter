import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mercadinho_app/components/inputlogin.dart';
import 'package:mercadinho_app/screens/telalogin.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final emailDigitado = TextEditingController();
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    emailDigitado.text = usuarioEmail?.toString() ?? '';
  }

  Future<void> fazerPatch() async {
    if (emailDigitado.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Digite um e-mail válido")));
      return;
    }
    setState(() => salvando = true);
    final resposta = await http.patch(
      Uri.parse("https://mercadinho-api-ouaq.onrender.com/usuarios/$usuarioId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": emailDigitado.text.trim()}),
    );
    if (!mounted) return;
    setState(() => salvando = false);
    if (resposta.statusCode == 200) {
      usuarioEmail = emailDigitado.text.trim();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil atualizado com sucesso")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao atualizar o perfil"), backgroundColor: Colors.red));
    }
  }

  void finalizarSessao() {
    usuarioId = null;
    usuarioEmail = null;
    statusAdmin = null;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const TelaLogin()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu perfil"), automaticallyImplyLeading: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CircleAvatar(radius: 42, backgroundColor: Color(0xffeeeaff), child: Icon(Icons.person_outline, size: 48, color: Color(0xff4b27b8))),
                    const SizedBox(height: 16),
                    const Text("Dados da conta", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    InputLogin(fofoqueira: emailDigitado, placeholder: "E-mail", tipo: TextInputType.emailAddress, icone: Icons.email_outlined),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: salvando ? null : fazerPatch,
                      icon: salvando ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined),
                      label: const Text("Salvar alterações"),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: finalizarSessao,
                      icon: const Icon(Icons.logout),
                      label: const Text("Sair da conta"),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent), padding: const EdgeInsets.symmetric(vertical: 15)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
