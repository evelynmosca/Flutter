import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalService {
  static const urlEmulador = 'http://10.0.2.2:8765';
  static const urlComputador = 'http://127.0.0.1:8765';
  static String get urlPadrao =>
      kIsWeb || defaultTargetPlatform != TargetPlatform.android
      ? urlComputador
      : urlEmulador;
  static const _chaveUrlApi = 'url_api';
  static const _chaveFavoritos = 'produtos_favoritos';
  static const _chaveNome = 'contato_nome';
  static const _chaveTelefone = 'contato_telefone';

  final FlutterSecureStorage _armazenamentoSeguro;

  LocalService({FlutterSecureStorage? armazenamentoSeguro})
    : _armazenamentoSeguro =
          armazenamentoSeguro ?? const FlutterSecureStorage();

  Future<String> carregarUrlApi() async {
    final preferencias = await SharedPreferences.getInstance();
    final urlSalva = preferencias.getString(_chaveUrlApi);
    final enderecoLocal =
        urlSalva == urlEmulador ||
        urlSalva == urlComputador ||
        urlSalva == 'http://localhost:8765';
    if (enderecoLocal && urlSalva != urlPadrao) {
      final salvou = await preferencias.setString(_chaveUrlApi, urlPadrao);
      if (!salvou) throw StateError('Não foi possível corrigir a URL da API.');
      return urlPadrao;
    }
    return urlSalva ?? urlPadrao;
  }

  Future<void> salvarUrlApi(String url) async {
    final endereco = url.trim().replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(endereco);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.path.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError(
        'Digite a URL raiz da API, começando com http:// ou https://.',
      );
    }
    final preferencias = await SharedPreferences.getInstance();
    final enderecoAnterior = (preferencias.getString(_chaveUrlApi) ?? urlPadrao)
        .trim()
        .replaceFirst(RegExp(r'/+$'), '');
    if (enderecoAnterior != endereco) {
      final limpou = await preferencias.setStringList(_chaveFavoritos, []);
      if (!limpou) {
        throw StateError(
          'Não foi possível limpar os favoritos da API anterior.',
        );
      }
    }
    final salvou = await preferencias.setString(_chaveUrlApi, endereco);
    if (!salvou) throw StateError('Não foi possível salvar o endereço da API.');
  }

  Future<Set<int>> carregarFavoritos() async {
    final preferencias = await SharedPreferences.getInstance();
    final lista = preferencias.getStringList(_chaveFavoritos) ?? [];
    return lista.map(int.tryParse).whereType<int>().toSet();
  }

  // Retorna true quando o produto passa a ser favorito.
  Future<bool> alternarFavorito(int id) async {
    final favoritos = await carregarFavoritos();
    final adicionado = favoritos.add(id);
    if (!adicionado) favoritos.remove(id);

    final preferencias = await SharedPreferences.getInstance();
    final lista = favoritos.map((item) => item.toString()).toList()..sort();
    final salvou = await preferencias.setStringList(_chaveFavoritos, lista);
    if (!salvou) throw StateError('Não foi possível salvar os favoritos.');
    return adicionado;
  }

  Future<Map<String, String>> carregarContato() async {
    final nome = await _armazenamentoSeguro.read(key: _chaveNome) ?? '';
    final telefone = await _armazenamentoSeguro.read(key: _chaveTelefone) ?? '';
    return {'nome': nome, 'telefone': telefone};
  }

  Future<void> salvarContato(String nome, String telefone) async {
    await _armazenamentoSeguro.write(key: _chaveNome, value: nome.trim());
    await _armazenamentoSeguro.write(
      key: _chaveTelefone,
      value: telefone.trim(),
    );
  }
}
