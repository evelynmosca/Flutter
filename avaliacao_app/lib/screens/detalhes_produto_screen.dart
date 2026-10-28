import 'package:flutter/material.dart';

import '../components/produto_card.dart';
import '../models/produto.dart';
import '../services/local_service.dart';
import 'formulario_produto_screen.dart';

class DetalhesProdutoScreen extends StatefulWidget {
  const DetalhesProdutoScreen({super.key, required this.produto});

  final Produto produto;

  @override
  State<DetalhesProdutoScreen> createState() => _DetalhesProdutoScreenState();
}

class _DetalhesProdutoScreenState extends State<DetalhesProdutoScreen> {
  final LocalService _localService = LocalService();
  bool _favorito = false;

  @override
  void initState() {
    super.initState();
    _carregarFavorito();
  }

  Future<void> _carregarFavorito() async {
    final id = widget.produto.id;
    if (id == null) return;
    try {
      final favoritos = await _localService.carregarFavoritos();
      if (mounted) setState(() => _favorito = favoritos.contains(id));
    } catch (erro) {
      if (mounted) _mensagem('Não foi possível carregar os favoritos: $erro');
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _alternarFavorito() async {
    final id = widget.produto.id;
    if (id == null) return;
    try {
      final favorito = await _localService.alternarFavorito(id);
      if (!mounted) return;
      setState(() => _favorito = favorito);
      _mensagem(
        favorito
            ? 'Produto adicionado aos favoritos.'
            : 'Produto removido dos favoritos.',
      );
    } catch (erro) {
      if (mounted) _mensagem('Não foi possível salvar o favorito: $erro');
    }
  }

  Future<void> _editar() async {
    final salvo = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioProdutoScreen(produto: widget.produto),
      ),
    );
    if (salvo == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;
    final precoAtual = produto.precoAtual
        .toStringAsFixed(2)
        .replaceAll('.', ',');
    final precoOriginal = produto.preco.toStringAsFixed(2).replaceAll('.', ',');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do produto'),
        actions: [
          IconButton(
            tooltip: _favorito
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            onPressed: _alternarFavorito,
            icon: Icon(_favorito ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: ImagemProduto(url: produto.imagemUrl, tamanho: 220),
              ),
              const SizedBox(height: 18),
              Text(
                produto.nome,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                produto.categoria,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (produto.descontoPercentual > 0) ...[
                        Text(
                          'Promoção: ${produto.descontoPercentual.toStringAsFixed(0)}% de desconto',
                          style: const TextStyle(
                            color: Color(0xFFB42332),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'De R\$ $precoOriginal',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      Text(
                        'R\$ $precoAtual',
                        style: const TextStyle(
                          color: Color(0xFF4B27B8),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Descrição',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(produto.descricao, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _editar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar produto'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _alternarFavorito,
                icon: Icon(_favorito ? Icons.favorite : Icons.favorite_border),
                label: Text(
                  _favorito ? 'Remover dos favoritos' : 'Salvar nos favoritos',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
