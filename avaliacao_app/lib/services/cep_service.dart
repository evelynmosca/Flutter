import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CepException implements Exception {
  final String mensagem;

  CepException(this.mensagem);

  @override
  String toString() => mensagem;
}

class CepService {
  final http.Client _cliente;

  CepService({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  Future<String> consultarCep(String cep) async {
    final texto = cep.trim();
    if (!RegExp(r'^(\d{8}|\d{5}-\d{3})$').hasMatch(texto)) {
      throw CepException(
        'Digite um CEP com 8 números ou no formato 00000-000.',
      );
    }
    final numeros = texto.replaceAll('-', '');

    try {
      final resposta = await _cliente
          .get(Uri.parse('https://viacep.com.br/ws/$numeros/json/'))
          .timeout(const Duration(seconds: 10));
      if (resposta.statusCode != 200) {
        throw CepException(
          'Não foi possível consultar o CEP. Tente novamente.',
        );
      }

      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (dados is! Map) {
        throw CepException('O serviço de CEP retornou dados inválidos.');
      }
      if (dados['erro'] == true) throw CepException('CEP não encontrado.');

      final cidade = dados['localidade']?.toString().trim() ?? '';
      final uf = dados['uf']?.toString().trim() ?? '';
      if (cidade.isEmpty || uf.isEmpty) {
        throw CepException('O serviço de CEP retornou dados inválidos.');
      }

      final logradouro = dados['logradouro']?.toString().trim() ?? '';
      final bairro = dados['bairro']?.toString().trim() ?? '';
      final cepFormatado = dados['cep']?.toString() ?? cep;
      final partes = <String>[
        if (logradouro.isNotEmpty) logradouro,
        if (bairro.isNotEmpty) bairro,
        '$cidade - $uf',
      ];
      return '${partes.join(', ')} (CEP $cepFormatado)';
    } on CepException {
      rethrow;
    } on TimeoutException {
      throw CepException('A consulta do CEP demorou para responder.');
    } on FormatException {
      throw CepException('O serviço de CEP retornou dados inválidos.');
    } catch (_) {
      throw CepException('Não foi possível conectar ao serviço de CEP.');
    }
  }

  void fechar() => _cliente.close();
}
