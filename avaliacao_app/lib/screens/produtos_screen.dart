import 'package:flutter/material.dart';

import '../components/produto_card.dart';
import '../models/produto.dart';
import '../services/api_service.dart';
import '../services/local_service.dart';
import 'detalhes_produto_screen.dart';
import 'formulario_produto_screen.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final LocalService _localService = LocalService();
  List<Produto> _produtos = [];
  String _busca = '';
  String _categoria = 'Todas';
  String? _erro;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final url = await _localService.carregarUrlApi();
      final api = ApiService(url);
      List<Produto> produtos;
      try {
        produtos = await api.listarProdutos();
      } finally {
        api.fechar();
      }
      if (!mounted) return;
      setState(() {
        _produtos = produtos;
        if (!produtos.any((produto) => produto.categoria == _categoria)) {
          _categoria = 'Todas';
        }
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _erro = erro.toString();
        _carregando = false;
      });
    }
  }

  List<Produto> get _produtosFiltrados {
    final texto = _busca.toLowerCase().trim();
    return _produtos.where((produto) {
      final mesmaCategoria =
          _categoria == 'Todas' || produto.categoria == _categoria;
      final corresponde =
          texto.isEmpty ||
          produto.nome.toLowerCase().contains(texto) ||
          produto.descricao.toLowerCase().contains(texto) ||
          produto.categoria.toLowerCase().contains(texto);
      return mesmaCategoria && corresponde;
    }).toList();
  }

  Future<void> _abrirDetalhes(Produto produto) async {
    final alterado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesProdutoScreen(produto: produto),
      ),
    );
    if (alterado == true && mounted) {
      _carregar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto atualizado com sucesso.')),
      );
    }
  }

  Future<void> _novoProduto() async {
    final salvo = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const FormularioProdutoScreen()),
    );
    if (salvo == true && mounted) {
      _carregar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto cadastrado com sucesso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias =
        _produtos.map((produto) => produto.categoria).toSet().toList()..sort();
    final filtrados = _produtosFiltrados;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            tooltip: 'Gerenciar produtos',
            onPressed: () async {
              await Navigator.pushNamed(context, '/gerenciamento');
              if (mounted) _carregar();
            },
            icon: const Icon(Icons.edit_note),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoProduto,
        icon: const Icon(Icons.add),
        label: const Text('Cadastrar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: TextField(
                onChanged: (valor) => setState(() => _busca = valor),
                decoration: const InputDecoration(
                  labelText: 'Buscar produto',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          if (categorias.isNotEmpty)
            SizedBox(
              height: 54,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final categoria in ['Todas', ...categorias])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(categoria),
                          selected: _categoria == categoria,
                          onSelected: (_) =>
                              setState(() => _categoria = categoria),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _carregar,
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _erro != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        const Icon(Icons.wifi_off, size: 52),
                        const SizedBox(height: 12),
                        Text(
                          'Erro ao carregar produtos: $_erro',
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: _carregar,
                          child: const Text('Tentar novamente'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              '/configuracoes',
                            );
                            if (mounted) _carregar();
                          },
                          child: const Text('Configurar conexão'),
                        ),
                      ],
                    )
                  : filtrados.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 52),
                        const SizedBox(height: 12),
                        Text(
                          _produtos.isEmpty
                              ? 'Nenhum produto cadastrado. Toque em Cadastrar para começar.'
                              : 'Nenhum produto corresponde à busca.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: filtrados.length,
                      itemBuilder: (context, indice) {
                        final produto = filtrados[indice];
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: ProdutoCard(
                              produto: produto,
                              onTap: () => _abrirDetalhes(produto),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
