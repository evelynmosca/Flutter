import 'package:flutter/material.dart';

import '../components/produto_card.dart';
import '../models/produto.dart';
import '../services/api_service.dart';
import '../services/local_service.dart';
import 'detalhes_produto_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalService _localService = LocalService();
  List<Produto> _produtos = [];
  String _nomeCliente = '';
  String? _erro;
  String? _erroContato;
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
      _erroContato = null;
    });
    String nomeCliente = '';
    String? erroContato;
    try {
      final contato = await _localService.carregarContato();
      nomeCliente = contato['nome'] ?? '';
    } catch (_) {
      erroContato = 'Não foi possível ler o contato salvo no aparelho.';
    }
    if (!mounted) return;
    setState(() {
      _nomeCliente = nomeCliente;
      _erroContato = erroContato;
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

  Future<void> _abrirRota(String rota) async {
    await Navigator.pushNamed(context, rota);
    if (mounted) _carregar();
  }

  Future<void> _abrirDetalhes(Produto produto) async {
    final alterado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesProdutoScreen(produto: produto),
      ),
    );
    if (alterado == true && mounted) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final destaques = _produtos
        .where((produto) => produto.descontoPercentual > 0)
        .take(3)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercadinho Genciana'),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            onPressed: () => _abrirRota('/configuracoes'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4B27B8), Color(0xFF7B5CD6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.storefront, color: Colors.white, size: 34),
                  const SizedBox(height: 16),
                  Text(
                    _nomeCliente.isEmpty
                        ? 'Bem-vindo ao Mercadinho Genciana!'
                        : 'Olá, $_nomeCliente!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Produtos do bairro, preços claros e ofertas para você.',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_erroContato != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _erroContato!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sobre a loja',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Uma vitrine digital para um mercadinho de bairro. Consulte os produtos e as promoções cadastradas pela loja.',
                    ),
                    const SizedBox(height: 10),
                    Text('Produtos cadastrados: ${_produtos.length}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Acesso rápido',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final estreito = constraints.maxWidth < 380;
                final largura = estreito
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Atalho(
                      largura: largura,
                      titulo: 'Ver produtos',
                      icone: Icons.shopping_basket_outlined,
                      onTap: () => _abrirRota('/produtos'),
                    ),
                    _Atalho(
                      largura: largura,
                      titulo: 'Gerenciar',
                      icone: Icons.edit_note,
                      onTap: () => _abrirRota('/gerenciamento'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Promoções em destaque',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_carregando)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_erro != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Não foi possível carregar os produtos. $_erro'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: _carregar,
                            child: const Text('Tentar novamente'),
                          ),
                          TextButton(
                            onPressed: () => _abrirRota('/configuracoes'),
                            child: const Text('Configurar API'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else if (destaques.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhuma promoção cadastrada no momento.'),
                ),
              )
            else
              ...destaques.map(
                (produto) => ProdutoCard(
                  produto: produto,
                  onTap: () => _abrirDetalhes(produto),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Atalho extends StatelessWidget {
  const _Atalho({
    required this.largura,
    required this.titulo,
    required this.icone,
    required this.onTap,
  });

  final double largura;
  final String titulo;
  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(icone, color: const Color(0xFF4B27B8)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
