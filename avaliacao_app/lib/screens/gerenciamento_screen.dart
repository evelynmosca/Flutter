import 'package:flutter/material.dart';

import '../components/produto_card.dart';
import '../models/produto.dart';
import '../services/api_service.dart';
import '../services/local_service.dart';
import 'detalhes_produto_screen.dart';
import 'formulario_produto_screen.dart';

class GerenciamentoScreen extends StatefulWidget {
  const GerenciamentoScreen({super.key});

  @override
  State<GerenciamentoScreen> createState() => _GerenciamentoScreenState();
}

class _GerenciamentoScreenState extends State<GerenciamentoScreen> {
  final LocalService _localService = LocalService();
  List<Produto> _produtos = [];
  String? _erro;
  bool _carregando = true;
  int? _excluindoId;

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

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _abrirFormulario([Produto? produto]) async {
    final salvo = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioProdutoScreen(produto: produto),
      ),
    );
    if (salvo == true && mounted) {
      _carregar();
      _mensagem(
        produto == null
            ? 'Produto cadastrado com sucesso.'
            : 'Produto atualizado com sucesso.',
      );
    }
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
      _mensagem('Produto atualizado com sucesso.');
    }
  }

  Future<void> _excluir(Produto produto) async {
    final id = produto.id;
    if (id == null || _excluindoId != null) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text(
          'Deseja excluir "${produto.nome}"? Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    setState(() => _excluindoId = id);
    try {
      final url = await _localService.carregarUrlApi();
      final api = ApiService(url);
      try {
        await api.excluirProduto(id);
      } finally {
        api.fechar();
      }
      if (!mounted) return;
      _mensagem('Produto excluído com sucesso.');
      await _carregar();
    } catch (erro) {
      if (mounted) _mensagem('Não foi possível excluir: $erro');
    } finally {
      if (mounted) setState(() => _excluindoId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciamento')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
      body: RefreshIndicator(
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
                      await Navigator.pushNamed(context, '/configuracoes');
                      if (mounted) _carregar();
                    },
                    child: const Text('Configurar conexão'),
                  ),
                ],
              )
            : _produtos.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  Icon(Icons.inventory_2_outlined, size: 52),
                  SizedBox(height: 12),
                  Text(
                    'Nenhum produto cadastrado. Toque em Novo produto.',
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: _produtos.length,
                itemBuilder: (context, indice) {
                  final produto = _produtos[indice];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: ProdutoCard(
                        produto: produto,
                        onTap: () => _abrirDetalhes(produto),
                        acoes: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Editar ${produto.nome}',
                              onPressed: () => _abrirFormulario(produto),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Excluir ${produto.nome}',
                              onPressed: _excluindoId == null
                                  ? () => _excluir(produto)
                                  : null,
                              icon: _excluindoId == produto.id
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
