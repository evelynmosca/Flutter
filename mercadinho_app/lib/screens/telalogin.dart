import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _roxo = Color(0xff5420c9);
const _roxoClaro = Color(0xff8b45f5);

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

  @override
  void dispose() { emailDigitado.dispose(); senhaDigitada.dispose(); super.dispose(); }

  Future<void> fazerLogin() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => carregando = true);
    try {
      final resposta = await http.get(Uri.parse('https://mercadinho-api-ouaq.onrender.com/usuarios'));
      if (!mounted) return;
      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body) as List<dynamic>;
        dynamic usuario;
        for (final item in dados) {
          if (item['email'] == emailDigitado.text.trim() && item['senha'] == senhaDigitada.text) { usuario = item; break; }
        }
        if (usuario != null) {
          usuarioId = usuario['id']; usuarioEmail = usuario['email']; statusAdmin = usuario['admin'];
          Navigator.pushNamed(context, '/navbar'); return;
        }
        _mensagem('E-mail ou senha inválidos');
      } else { _mensagem('Não foi possível conectar ao servidor'); }
    } catch (_) { if (mounted) _mensagem('Não foi possível conectar ao servidor'); }
    if (mounted) setState(() => carregando = false);
  }

  void _mensagem(String texto) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  InputDecoration _campo(String texto, IconData icone) => InputDecoration(
    hintText: texto, hintStyle: const TextStyle(color: Color(0xff77748d), fontSize: 13),
    prefixIcon: Icon(icone, color: const Color(0xff494461), size: 20), filled: true,
    fillColor: const Color(0xfff3f1fc), contentPadding: const EdgeInsets.symmetric(vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _roxoClaro, width: 1.5)),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Entrar')), backgroundColor: const Color(0xfff8f8ff),
    body: Stack(children: [
      const Positioned(top: -130, left: -90, child: _DecorativeCircle(size: 320)),
      const Positioned(bottom: -150, right: -70, child: _DecorativeCircle(size: 300)),
      Positioned.fill(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 112), child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 410), child: Container(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .9), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white, width: 1.5), boxShadow: const [BoxShadow(color: Color(0x220f0960), blurRadius: 28, offset: Offset(0, 14))]),
          child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const _LoginMark(), const SizedBox(height: 12),
            const Text('Bem-vindo!', textAlign: TextAlign.center, style: TextStyle(color: Color(0xff171329), fontSize: 23, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5), const Text('Faça login para acessar seu catálogo\nde produtos.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xff77738f), fontSize: 12, height: 1.35)),
            const SizedBox(height: 22),
            TextFormField(controller: emailDigitado, keyboardType: TextInputType.emailAddress, validator: (v) => v == null || v.trim().isEmpty ? 'Digite seu e-mail' : null, decoration: _campo('E-mail', Icons.mail_outline)),
            const SizedBox(height: 12), TextFormField(controller: senhaDigitada, obscureText: true, validator: (v) => v == null || v.isEmpty ? 'Digite sua senha' : null, decoration: _campo('Senha', Icons.lock_outline)),
            const SizedBox(height: 17), SizedBox(height: 48, child: DecoratedBox(decoration: BoxDecoration(gradient: const LinearGradient(colors: [_roxo, _roxoClaro]), borderRadius: BorderRadius.circular(25)), child: ElevatedButton.icon(onPressed: carregando ? null : fazerLogin, icon: const Icon(Icons.arrow_forward, size: 19), label: carregando ? const SizedBox(height: 19, width: 19, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Entrar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))))))
          ])),
        ),
      )))),
    ]),
  );
}

class _LoginMark extends StatelessWidget {
  const _LoginMark();
  @override
  Widget build(BuildContext context) => Center(child: Container(width: 48, height: 48, decoration: BoxDecoration(color: _roxo, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x443f13af), blurRadius: 12, offset: Offset(0, 5))]), child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 28)));
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  const _DecorativeCircle({required this.size});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0x339b7bff), Color(0x119b7bff)])));
}

dynamic usuarioId;
dynamic usuarioEmail;
bool? statusAdmin;