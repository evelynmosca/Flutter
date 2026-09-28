import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _roxoGestao = Color(0xff5420c9);
const _roxoGestaoClaro = Color(0xff9146f6);

class TelaGestao extends StatefulWidget {
  const TelaGestao({super.key});

  @override
  State<TelaGestao> createState() => _TelaGestaoState();
}

class _TelaGestaoState extends State<TelaGestao> {
  final nomeDigitado = TextEditingController();
  final urlDigitado = TextEditingController();
  final precoDigitado = TextEditingController();

  List<dynamic> listaProdutos = [];
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    fazerGet();
  }

  @override
  void dispose() {
    nomeDigitado.dispose();
    urlDigitado.dispose();
    precoDigitado.dispose();
    super.dispose();
  }

  Future<void> fazerPost() async {
    final preco = double.tryParse(precoDigitado.text.replaceAll(',', '.'));

    if (nomeDigitado.text.trim().isEmpty ||
        urlDigitado.text.trim().isEmpty ||
        preco == null) {
      _mensagem('Preencha todos os campos corretamente');
      return;
    }

    setState(() => carregando = true);

    try {
      final resposta = await http.post(
        Uri.parse('https://mercadinho-api-ouaq.onrender.com/produtos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nomeDigitado.text.trim(),
          'imagem': urlDigitado.text.trim(),
          'preco': preco,
        }),
      );

      if (!mounted) return;

      if (resposta.statusCode == 201) {
        nomeDigitado.clear();
        urlDigitado.clear();
        precoDigitado.clear();
        _mensagem('Produto criado com sucesso!');
        await fazerGet();
      } else {
        _mensagem('Erro ao criar produto.');
      }
    } catch (_) {
      if (mounted) _mensagem('Não foi possível conectar ao servidor');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> fazerGet() async {
    try {
      final resposta = await http.get(
        Uri.parse('https://mercadinho-api-ouaq.onrender.com/produtos'),
      );

      if (resposta.statusCode == 200 && mounted) {
        final dados = jsonDecode(resposta.body);
        if (dados is List) {
          setState(() => listaProdutos = dados);
        }
      }
    } catch (_) {
      // A lista continua vazia se o servidor estiver indisponível.
    }
  }

  Future<void> fazerDelete(dynamic id) async {
    try {
      final resposta = await http.delete(
        Uri.parse('https://mercadinho-api-ouaq.onrender.com/produtos/$id'),
      );

      if (!mounted) return;

      if (resposta.statusCode == 200) {
        _mensagem('Produto removido.');
        await fazerGet();
      } else {
        _mensagem('Falha ao remover produto.');
      }
    } catch (_) {
      if (mounted) _mensagem('Falha ao remover produto.');
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  InputDecoration _decoracaoCampo(String texto, IconData icone) {
    return InputDecoration(
      hintText: texto,
      hintStyle: const TextStyle(color: Color(0xff77748d), fontSize: 13),
      prefixIcon: Icon(icone, color: const Color(0xff494461), size: 20),
      filled: true,
      fillColor: const Color(0xfff3f1fc),
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _roxoGestaoClaro, width: 1.5),
      ),
    );
  }

  Widget campo(
    TextEditingController controller,
    String texto,
    IconData icone, {
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: _decoracaoCampo(texto, icone),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão de produtos')),
      backgroundColor: const Color(0xfff8f8ff),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _formularioProduto(),
          const SizedBox(height: 20),
          _tituloProdutos(),
          const SizedBox(height: 9),
          if (listaProdutos.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Nenhum produto cadastrado.'),
              ),
            ),
          for (final produto in listaProdutos) _produtoItem(produto),
        ],
      ),
    );
  }

  Widget _formularioProduto() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100d0950),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NOVO PRODUTO',
                      style: TextStyle(
                        color: _roxoGestaoClaro,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Adicionar produto',
                      style: TextStyle(
                        color: Color(0xff171329),
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cadastre um novo item no seu catálogo',
                      style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const _ProductDecoration(),
            ],
          ),
          const SizedBox(height: 17),
          campo(nomeDigitado, 'Nome do produto', Icons.inventory_2_outlined),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: campo(
                  urlDigitado,
                  'URL da imagem',
                  Icons.image_outlined,
                  tipo: TextInputType.url,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: campo(
                  precoDigitado,
                  'Preço',
                  Icons.sell_outlined,
                  tipo: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_roxoGestao, _roxoGestaoClaro],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton.icon(
                onPressed: carregando ? null : fazerPost,
                icon: const Icon(Icons.add, size: 20),
                label: carregando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Adicionar produto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloProdutos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Produtos cadastrados',
          style: TextStyle(
            color: Color(0xff171329),
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (listaProdutos.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xfff0eaff),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${listaProdutos.length} produtos',
              style: const TextStyle(
                color: _roxoGestao,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _produtoItem(dynamic produto) {
    final preco = double.tryParse('${produto['preco']}') ?? 0;
    final imagem = '${produto['imagem']}';
    final nome = '${produto['nome']}';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0d0d0950),
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.network(
              imagem,
              width: 49,
              height: 49,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 49,
                height: 49,
                color: const Color(0xffeeeaff),
                child: const Icon(Icons.image_outlined, color: _roxoGestao),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff28243e),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xfff0eaff),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: _roxoGestao,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => fazerDelete(produto['id']),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xffffeeee),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDecoration extends StatelessWidget {
  const _ProductDecoration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xffeeeaff),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_roxoGestao, _roxoGestaoClaro],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 31),
          ),
          const Positioned(
            top: 7,
            right: 8,
            child: Icon(Icons.auto_awesome, color: _roxoGestaoClaro, size: 15),
          ),
        ],
      ),
    );
  }
}