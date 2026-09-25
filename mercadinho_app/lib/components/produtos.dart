import 'package:flutter/material.dart';
import 'package:mercadinho_app/components/carrinho.dart';

class ProdutosCard extends StatelessWidget {
  final String nome;
  final double preco;
  final String urlImagem;

  const ProdutosCard({super.key, required this.nome, required this.preco, required this.urlImagem});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Image.network(urlImagem, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 48)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
            child: Text(nome, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Text("R\$ ${preco.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xff5b35d5), fontWeight: FontWeight.w600)),
          IconButton(
            onPressed: () {
              final indice = produtosCarrinho.indexWhere((item) => item.nome == nome && item.urlImagem == urlImagem);
              if (indice >= 0) {
                produtosCarrinho[indice].quantidade++;
              } else {
                produtosCarrinho.add(ItemCarrinho(nome: nome, preco: preco, urlImagem: urlImagem));
              }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produto adicionado ao carrinho")));
            },
            icon: const Icon(Icons.add_shopping_cart),
            color: const Color(0xff4b27b8),
          )
        ],
      )
    );
  }
}
