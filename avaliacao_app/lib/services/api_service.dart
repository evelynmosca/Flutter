import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:avaliacao_app/models/produto.dart';

class ApiException implements Exception {
  final String mensagem;
  final int? statusCode;

  ApiException(this.mensagem, {this.statusCode});

  @override
  String toString() => mensagem;
}

class ApiService {
  final String baseUrl;
  final http.Client _cliente;
  static const _tempoLimite = Duration(seconds: 15);

  ApiService(String baseUrl, {http.Client? cliente})
    : baseUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), ''),
      _cliente = cliente ?? http.Client();

  Uri _endereco(String caminho) => Uri.parse('$baseUrl$caminho');

  Future<bool> verificarConexao() async {
    try {
      final resposta = await _requisitar(
        () => _cliente.get(_endereco('/saude')),
      );
      return resposta.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Produto>> listarProdutos() async {
    final resposta = await _requisitar(
      () => _cliente.get(_endereco('/produtos')),
    );
    _verificarStatus(resposta, [200]);
    try {
      final dados = _lerJson(resposta);
      if (dados is! List) throw const FormatException();
      return dados
          .map(
            (item) => Produto.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      throw ApiException('A API retornou uma lista de produtos inválida.');
    }
  }

  Future<Produto> buscarProduto(int id) async {
    final resposta = await _requisitar(
      () => _cliente.get(_endereco('/produtos/$id')),
    );
    _verificarStatus(resposta, [200]);
    return _lerProduto(resposta);
  }

  Future<Produto> cadastrarProduto(Produto produto) async {
    final resposta = await _requisitar(
      () => _cliente.post(
        _endereco('/produtos'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(produto.toJson()),
      ),
    );
    _verificarStatus(resposta, [200, 201]);
    return _lerProduto(resposta, original: produto);
  }

  Future<Produto> atualizarProduto(Produto produto) async {
    final id = produto.id;
    if (id == null) {
      throw ApiException('O produto precisa ter um ID para ser atualizado.');
    }
    final resposta = await _requisitar(
      () => _cliente.put(
        _endereco('/produtos/$id'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(produto.toJson()),
      ),
    );
    _verificarStatus(resposta, [200, 204]);
    return _lerProduto(resposta, original: produto);
  }

  Future<void> excluirProduto(int id) async {
    final resposta = await _requisitar(
      () => _cliente.delete(_endereco('/produtos/$id')),
    );
    _verificarStatus(resposta, [200, 204]);
  }

  void fechar() => _cliente.close();

  Future<http.Response> _requisitar(
    Future<http.Response> Function() enviar,
  ) async {
    try {
      return await enviar().timeout(_tempoLimite);
    } on TimeoutException {
      throw ApiException(
        'A API em $baseUrl demorou para responder. Confira se o servidor está ligado e se a URL está correta em Configurações.',
      );
    } on http.ClientException {
      throw ApiException(
        'Não foi possível conectar à API em $baseUrl. Ligue o servidor no computador ou confira a URL em Configurações.',
      );
    } catch (_) {
      throw ApiException(
        'Não foi possível conectar à API em $baseUrl. Ligue o servidor no computador ou confira a URL em Configurações.',
      );
    }
  }

  void _verificarStatus(http.Response resposta, List<int> esperados) {
    if (esperados.contains(resposta.statusCode)) return;

    String mensagem;
    switch (resposta.statusCode) {
      case 400:
      case 422:
        mensagem = 'Dados inválidos para a API.';
      case 404:
        mensagem = 'Produto não encontrado na API.';
      case 409:
        mensagem = 'Este produto já existe na API.';
      default:
        mensagem = resposta.statusCode >= 500
            ? 'Erro no servidor da API.'
            : 'Falha na API (código ${resposta.statusCode}).';
    }

    try {
      final dados = _lerJson(resposta);
      if (dados is Map) {
        final detalhe =
            dados['erro'] ??
            dados['mensagem'] ??
            dados['detail'] ??
            dados['error'];
        if (detalhe is String && detalhe.trim().isNotEmpty) {
          mensagem = '$mensagem ${detalhe.trim()}';
        }
      }
    } catch (_) {
      // A mensagem padrão já informa a falha mesmo se o servidor retornar HTML.
    }
    throw ApiException(mensagem, statusCode: resposta.statusCode);
  }

  dynamic _lerJson(http.Response resposta) {
    return jsonDecode(utf8.decode(resposta.bodyBytes));
  }

  Produto _lerProduto(http.Response resposta, {Produto? original}) {
    if (resposta.bodyBytes.isEmpty && original != null) return original;
    try {
      final dados = _lerJson(resposta);
      if (dados is! Map) throw const FormatException();
      final valores = <String, dynamic>{
        if (original != null) ...original.toJson(),
        if (original?.id != null) 'id': original!.id,
        ...Map<String, dynamic>.from(dados),
      };
      return Produto.fromJson(valores);
    } catch (_) {
      throw ApiException('A API retornou dados do produto inválidos.');
    }
  }
}
