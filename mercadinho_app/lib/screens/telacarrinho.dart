import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mercadinho_app/components/carrinho.dart';
import 'package:http/http.dart' as http;
import 'package:mercadinho_app/screens/telalogin.dart';

class TelaCarrinho extends StatefulWidget {
  const TelaCarrinho({super.key});

  @override
  State<TelaCarrinho> createState() => _TelaCarrinhoState();
}
class _TelaCarrinhoState extends State<TelaCarrinho> {
  double get total => produtosCarrinho.fold(0, (soma, produto) => soma + produto.preco * produto.quantidade);

  void fazerPost() async{
    dynamic itensPedido = produtosCarrinho.map((produto){
      return{
        "Nome do produto":produto.nome,
        "quantidade": produto.quantidade
      };
    }).toList();

    final respostaServidor = await http.post(Uri.parse("https://mercadinho-api-ouaq.onrender.com/pedidos"),
    headers: {"Content-Type":"application/json"},
    body: jsonEncode({
      "usuarioId": usuarioId,
      "total": total,
      "itens": itensPedido 
    })
    );

    if(respostaServidor.statusCode == 201){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dado criado com sucesso!")));
        produtosCarrinho.clear();
        setState(() {});
      }
    }else{
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao criar pedido.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu carrinho"), automaticallyImplyLeading: false),
      body: produtosCarrinho.isEmpty ? const Center(child: Text("Seu carrinho está vazio\nAdicione produtos na Home", textAlign: TextAlign.center)) :
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for(final produto in produtosCarrinho )
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(produto.urlImagem, width: 64, height: 64, fit: BoxFit.cover)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(produto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("R\$ ${produto.preco.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xff5b35d5))),
                  Row(children: [
                    IconButton(onPressed: () { setState(() { if (produto.quantidade > 1) produto.quantidade--; }); }, icon: const Icon(Icons.remove_circle_outline), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    Text('${produto.quantidade}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () { setState(() => produto.quantidade++); }, icon: const Icon(Icons.add_circle_outline), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  ])
                ])),
                IconButton(onPressed: () { setState(() => produtosCarrinho.remove(produto)); }, icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
              ]),
            ),
          ),
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("R\$ ${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff4b27b8))),
          ]))),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: fazerPost, icon: const Icon(Icons.check), label: const Text("Finalizar pedido"))
        ],
      )
    );
  }
}
