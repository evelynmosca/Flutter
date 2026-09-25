import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelaGestao extends StatefulWidget {
  const TelaGestao({super.key});
  @override
  State<TelaGestao> createState() => _TelaGestaoState();
}

class _TelaGestaoState extends State<TelaGestao> {
  final nomeDigitado = TextEditingController();
  final urlDigitado = TextEditingController();
  final precoDigitado = TextEditingController();
  List listaProdutos = [];

  @override
  void initState() { super.initState(); fazerGet(); }

  Future<void> fazerPost() async {
    final preco = double.tryParse(precoDigitado.text.replaceAll(',', '.'));
    if (nomeDigitado.text.trim().isEmpty || urlDigitado.text.trim().isEmpty || preco == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha todos os campos corretamente")));
      return;
    }
    final resposta = await http.post(Uri.parse("https://mercadinho-api-ouaq.onrender.com/produtos"), headers: {"Content-Type":"application/json"}, body: jsonEncode({"nome": nomeDigitado.text.trim(), "imagem": urlDigitado.text.trim(), "preco": preco}));
    if (!mounted) return;
    if (resposta.statusCode == 201) {
      nomeDigitado.clear(); urlDigitado.clear(); precoDigitado.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produto criado com sucesso!")));
      fazerGet();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao criar produto."), backgroundColor: Colors.red));
    }
  }

  Future<void> fazerGet() async {
    final resposta = await http.get(Uri.parse("https://mercadinho-api-ouaq.onrender.com/produtos"));
    if (resposta.statusCode == 200 && mounted) setState(() => listaProdutos = jsonDecode(resposta.body));
  }

  Future<void> fazerDelete(dynamic id) async {
    final resposta = await http.delete(Uri.parse("https://mercadinho-api-ouaq.onrender.com/produtos/$id"));
    if (!mounted) return;
    if (resposta.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produto removido.")));
      fazerGet();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Falha ao remover produto.")));
    }
  }

  Widget campo(TextEditingController controller, String label, IconData icon, {TextInputType tipo = TextInputType.text}) => TextField(controller: controller, keyboardType: tipo, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), filled: true, fillColor: const Color(0xfff7f7fc), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xff4b27b8), width: 2))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestão de produtos")),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text("Adicionar produto", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text("Cadastre um novo item no seu catálogo", style: TextStyle(color: Colors.blueGrey.shade600)),
        const SizedBox(height: 18),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
          campo(nomeDigitado, "Nome do produto", Icons.shopping_bag_outlined),
          const SizedBox(height: 14),
          campo(urlDigitado, "URL da imagem", Icons.image_outlined, tipo: TextInputType.url),
          const SizedBox(height: 14),
          campo(precoDigitado, "Preço", Icons.sell_outlined, tipo: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: fazerPost, icon: const Icon(Icons.add), label: const Text("Adicionar produto"), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)))),
        ]))),
        const SizedBox(height: 28),
        const Text("Produtos cadastrados", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (listaProdutos.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20), child: Text("Nenhum produto cadastrado."))),
        for (final produto in listaProdutos) Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), leading: const CircleAvatar(backgroundColor: Color(0xffeeeaff), child: Icon(Icons.inventory_2_outlined, color: Color(0xff4b27b8))), title: Text(produto["nome"], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("R\$ ${double.tryParse('${produto["preco"]}')?.toStringAsFixed(2) ?? '0.00'}"), trailing: IconButton(onPressed: () => fazerDelete(produto["id"]), icon: const Icon(Icons.delete_outline, color: Colors.redAccent))))
      ]),
    );
  }
}
