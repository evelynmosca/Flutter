import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/cep_service.dart';
import '../services/local_service.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final LocalService _localService = LocalService();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  bool _carregando = true;
  bool _salvandoUrl = false;
  bool _salvandoContato = false;
  bool _testando = false;
  bool _consultandoCep = false;
  String? _enderecoCep;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    var url = LocalService.urlPadrao;
    var contato = <String, String>{};
    final falhas = <String>[];
    try {
      url = await _localService.carregarUrlApi();
    } catch (_) {
      falhas.add('URL da API');
    }
    try {
      contato = await _localService.carregarContato();
    } catch (_) {
      falhas.add('contato salvo');
    }
    if (!mounted) return;
    setState(() {
      _urlController.text = url;
      _nomeController.text = contato['nome'] ?? '';
      _telefoneController.text = contato['telefone'] ?? '';
      _carregando = false;
    });
    if (falhas.isNotEmpty) {
      _mensagem('Não foi possível ler: ${falhas.join(' e ')}.');
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _salvarUrl() async {
    setState(() => _salvandoUrl = true);
    try {
      await _localService.salvarUrlApi(_urlController.text);
      if (mounted) _mensagem('Endereço da API salvo neste dispositivo.');
    } catch (erro) {
      if (mounted) _mensagem('Não foi possível salvar: $erro');
    } finally {
      if (mounted) setState(() => _salvandoUrl = false);
    }
  }

  Future<void> _testarConexao() async {
    setState(() => _testando = true);
    final api = ApiService(_urlController.text);
    try {
      final conectou = await api.verificarConexao();
      if (mounted) {
        _mensagem(
          conectou
              ? 'Conexão com a API funcionando.'
              : 'Não foi possível conectar. Confira a URL e se o servidor está ligado.',
        );
      }
    } catch (erro) {
      if (mounted) _mensagem('Não foi possível testar a conexão: $erro');
    } finally {
      api.fechar();
      if (mounted) setState(() => _testando = false);
    }
  }

  Future<void> _salvarContato() async {
    setState(() => _salvandoContato = true);
    try {
      await _localService.salvarContato(
        _nomeController.text,
        _telefoneController.text,
      );
      if (mounted) _mensagem('Contato salvo com segurança no dispositivo.');
    } catch (erro) {
      if (mounted) _mensagem('Não foi possível salvar o contato: $erro');
    } finally {
      if (mounted) setState(() => _salvandoContato = false);
    }
  }

  Future<void> _consultarCep() async {
    setState(() {
      _consultandoCep = true;
      _enderecoCep = null;
    });
    final servico = CepService();
    try {
      final endereco = await servico.consultarCep(_cepController.text);
      if (mounted) setState(() => _enderecoCep = endereco);
    } catch (erro) {
      if (mounted) _mensagem('Consulta de CEP: $erro');
    } finally {
      servico.fechar();
      if (mounted) setState(() => _consultandoCep = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Conexão com o catálogo',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'A API guarda os produtos fora do aplicativo. No Chrome ou Windows, use 127.0.0.1; no emulador Android, 10.0.2.2. Em um celular, informe o IP do computador na mesma rede.',
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _urlController,
                                  keyboardType: TextInputType.url,
                                  decoration: InputDecoration(
                                    labelText: 'URL da API',
                                    hintText: LocalService.urlPadrao,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: _salvandoUrl
                                          ? null
                                          : _salvarUrl,
                                      icon: const Icon(Icons.save_outlined),
                                      label: const Text('Salvar URL'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: _testando
                                          ? null
                                          : _testarConexao,
                                      icon: const Icon(Icons.wifi_find),
                                      label: const Text('Testar conexão'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Meu contato',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Nome e telefone ficam somente neste aparelho, em armazenamento seguro. O nome aparece na tela inicial.',
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _nomeController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Nome',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _telefoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Telefone',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: _salvandoContato
                                      ? null
                                      : _salvarContato,
                                  icon: const Icon(Icons.lock_outline),
                                  label: const Text('Salvar contato'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Consultar endereço por CEP',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Consulta externa pelo ViaCEP, útil para conferir uma região de entrega.',
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _cepController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 9,
                                  decoration: const InputDecoration(
                                    labelText: 'CEP',
                                    hintText: '01001-000',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: _consultandoCep
                                      ? null
                                      : _consultarCep,
                                  icon: const Icon(Icons.place_outlined),
                                  label: Text(
                                    _consultandoCep
                                        ? 'Consultando...'
                                        : 'Consultar CEP',
                                  ),
                                ),
                                if (_enderecoCep != null) ...[
                                  const SizedBox(height: 12),
                                  SelectableText(_enderecoCep!),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
