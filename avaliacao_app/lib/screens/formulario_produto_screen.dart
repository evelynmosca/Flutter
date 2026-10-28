import 'package:flutter/material.dart';

import '../models/produto.dart';
import '../services/api_service.dart';
import '../services/local_service.dart';

class FormularioProdutoScreen extends StatefulWidget {
  const FormularioProdutoScreen({super.key, this.produto});

  final Produto? produto;

  @override
  State<FormularioProdutoScreen> createState() =>
      _FormularioProdutoScreenState();
}

class _FormularioProdutoScreenState extends State<FormularioProdutoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LocalService _localService = LocalService();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _precoController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _imagemController;
  late final TextEditingController _descontoController;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final produto = widget.produto;
    _nomeController = TextEditingController(text: produto?.nome ?? '');
    _descricaoController = TextEditingController(
      text: produto?.descricao ?? '',
    );
    _precoController = TextEditingController(
      text: produto == null
          ? ''
          : produto.preco.toStringAsFixed(2).replaceAll('.', ','),
    );
    _categoriaController = TextEditingController(
      text: produto?.categoria ?? '',
    );
    _imagemController = TextEditingController(text: produto?.imagemUrl ?? '');
    _descontoController = TextEditingController(
      text: produto == null
          ? '0'
          : produto.descontoPercentual.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _categoriaController.dispose();
    _imagemController.dispose();
    _descontoController.dispose();
    super.dispose();
  }

  double? _lerNumero(String texto) {
    return double.tryParse(texto.trim().replaceAll(',', '.'));
  }

  String? _validarObrigatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) return 'Informe $campo.';
    return null;
  }

  String? _validarPreco(String? valor) {
    final preco = _lerNumero(valor ?? '');
    if (preco == null || !preco.isFinite || preco <= 0) {
      return 'Informe um preço maior que zero.';
    }
    return null;
  }

  String? _validarDesconto(String? valor) {
    final desconto = _lerNumero((valor ?? '').isEmpty ? '0' : valor!);
    if (desconto == null ||
        !desconto.isFinite ||
        desconto < 0 ||
        desconto > 90) {
      return 'Use um desconto de 0% a 90%.';
    }
    return null;
  }

  String? _validarImagem(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return null;
    final uri = Uri.tryParse(texto);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Informe uma URL HTTP ou HTTPS válida.';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _salvando) return;
    setState(() => _salvando = true);

    final desconto = _lerNumero(_descontoController.text) ?? 0;
    final imagem = _imagemController.text.trim();
    final id = widget.produto?.id;
    final produto = desconto > 0
        ? ProdutoPromocional(
            id: id,
            nome: _nomeController.text.trim(),
            descricao: _descricaoController.text.trim(),
            preco: _lerNumero(_precoController.text)!,
            categoria: _categoriaController.text.trim(),
            imagemUrl: imagem.isEmpty ? null : imagem,
            descontoPercentual: desconto,
          )
        : Produto(
            id: id,
            nome: _nomeController.text.trim(),
            descricao: _descricaoController.text.trim(),
            preco: _lerNumero(_precoController.text)!,
            categoria: _categoriaController.text.trim(),
            imagemUrl: imagem.isEmpty ? null : imagem,
          );

    try {
      final url = await _localService.carregarUrlApi();
      final api = ApiService(url);
      try {
        if (id == null) {
          await api.cadastrarProduto(produto);
        } else {
          await api.atualizarProduto(produto);
        }
      } finally {
        api.fechar();
      }
      if (mounted) Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Não foi possível salvar: $erro')));
      setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.produto == null ? 'Cadastrar produto' : 'Editar produto',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Dados do produto',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Os produtos salvos ficam no banco de dados da API.',
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome *'),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (valor) => _validarObrigatorio(valor, 'o nome'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(labelText: 'Descrição *'),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (valor) =>
                        _validarObrigatorio(valor, 'a descrição'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _categoriaController,
                    decoration: const InputDecoration(labelText: 'Categoria *'),
                    textCapitalization: TextCapitalization.words,
                    validator: (valor) =>
                        _validarObrigatorio(valor, 'a categoria'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _precoController,
                    decoration: const InputDecoration(
                      labelText: 'Preço (R\$) *',
                      hintText: 'Ex.: 12,50',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _validarPreco,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descontoController,
                    decoration: const InputDecoration(
                      labelText: 'Desconto (%)',
                      helperText: 'Use 0 para produto sem promoção.',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _validarDesconto,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _imagemController,
                    decoration: const InputDecoration(
                      labelText: 'URL da imagem (opcional)',
                      hintText: 'https://...',
                    ),
                    keyboardType: TextInputType.url,
                    validator: _validarImagem,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_salvando ? 'Salvando...' : 'Salvar produto'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
