import 'dart:convert';

import 'package:avaliacao_app/models/produto.dart';
import 'package:avaliacao_app/services/api_service.dart';
import 'package:avaliacao_app/services/cep_service.dart';
import 'package:avaliacao_app/services/local_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('ProdutoPromocional calcula preço e converte JSON', () {
    final produto = Produto.fromJson({
      'id': 2,
      'nome': 'Banana',
      'descricao': 'Banana madura',
      'preco': '10.00',
      'categoria': 'Frutas',
      'imagem_url': null,
      'desconto_percentual': 20,
    });

    expect(produto, isA<ProdutoPromocional>());
    expect(produto.precoAtual, 8);
    expect(produto.toJson()['desconto_percentual'], 20);
  });

  test(
    'ApiService executa GET, POST, PUT e DELETE e lê o estado remoto',
    () async {
      final registros = <int, Map<String, dynamic>>{};
      var proximoId = 1;
      final cliente = MockClient((requisicao) async {
        final partes = requisicao.url.pathSegments;
        if (partes.length == 1 && partes.first == 'saude') {
          return http.Response('{"status":"ok"}', 200);
        }
        if (partes.isEmpty || partes.first != 'produtos') {
          return http.Response('{"erro":"Rota inexistente"}', 404);
        }
        final id = partes.length == 2 ? int.tryParse(partes[1]) : null;
        if (requisicao.method == 'GET' && id == null) {
          return http.Response(jsonEncode(registros.values.toList()), 200);
        }
        if (requisicao.method == 'POST' && id == null) {
          final novo = Map<String, dynamic>.from(
            jsonDecode(requisicao.body) as Map,
          );
          novo['id'] = proximoId++;
          registros[novo['id'] as int] = novo;
          return http.Response(jsonEncode(novo), 201);
        }
        if (id == null || !registros.containsKey(id)) {
          return http.Response('{"erro":"Produto inexistente"}', 404);
        }
        if (requisicao.method == 'GET') {
          return http.Response(jsonEncode(registros[id]), 200);
        }
        if (requisicao.method == 'PUT') {
          final atualizado = Map<String, dynamic>.from(
            jsonDecode(requisicao.body) as Map,
          );
          atualizado['id'] = id;
          registros[id] = atualizado;
          return http.Response(jsonEncode(atualizado), 200);
        }
        if (requisicao.method == 'DELETE') {
          registros.remove(id);
          return http.Response('', 204);
        }
        return http.Response('Método inválido', 405);
      });
      final api = ApiService('http://localhost:8765', cliente: cliente);

      expect(await api.verificarConexao(), isTrue);
      expect(await api.listarProdutos(), isEmpty);

      final criado = await api.cadastrarProduto(
        Produto(
          nome: 'Banana',
          descricao: 'Fruta fresca',
          preco: 6.5,
          categoria: 'Frutas',
        ),
      );
      expect(criado.id, 1);
      expect((await api.buscarProduto(1)).nome, 'Banana');
      expect((await api.listarProdutos()).length, 1);

      await api.atualizarProduto(
        ProdutoPromocional(
          id: criado.id,
          nome: 'Banana prata',
          descricao: 'Oferta do dia',
          preco: 6,
          categoria: 'Frutas',
          descontoPercentual: 25,
        ),
      );
      final atualizado = (await api.listarProdutos()).single;
      expect(atualizado.nome, 'Banana prata');
      expect(atualizado.precoAtual, 4.5);

      await api.excluirProduto(1);
      expect(await api.listarProdutos(), isEmpty);
      api.fechar();
    },
  );

  test('LocalService conserva URL e favoritos entre instâncias', () async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalService();
    expect(await local.carregarUrlApi(), LocalService.urlPadrao);
    await local.salvarUrlApi('http://192.168.1.10:8765/');
    expect(await local.alternarFavorito(7), isTrue);
    await local.salvarUrlApi('http://192.168.1.10:8765');
    expect(await local.carregarFavoritos(), {7});

    final outraInstancia = LocalService();
    expect(await outraInstancia.carregarUrlApi(), 'http://192.168.1.10:8765');
    expect(await outraInstancia.carregarFavoritos(), {7});
    expect(await outraInstancia.alternarFavorito(7), isFalse);
    expect(await local.carregarFavoritos(), isEmpty);

    await local.alternarFavorito(7);
    await local.salvarUrlApi('http://192.168.1.11:8765');
    expect(await outraInstancia.carregarFavoritos(), isEmpty);
  });

  test('LocalService corrige URL local para Chrome e Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      SharedPreferences.setMockInitialValues({
        'url_api': LocalService.urlEmulador,
        'produtos_favoritos': ['7'],
      });
      final local = LocalService();
      expect(LocalService.urlPadrao, LocalService.urlComputador);
      expect(await local.carregarUrlApi(), LocalService.urlComputador);
      final preferencias = await SharedPreferences.getInstance();
      expect(preferencias.getString('url_api'), LocalService.urlComputador);
      expect(await local.carregarFavoritos(), {7});

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(LocalService.urlPadrao, LocalService.urlEmulador);
      expect(await local.carregarUrlApi(), LocalService.urlEmulador);
      expect(preferencias.getString('url_api'), LocalService.urlEmulador);
      expect(await local.carregarFavoritos(), {7});
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  test('LocalService recusa URL que não seja a raiz da API', () async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalService();
    for (final url in [
      'http://localhost:8765/produtos',
      'http://localhost:8765?pagina=1',
      'http://localhost:8765#inicio',
      'http://usuario:senha@localhost:8765',
      'ftp://localhost:8765',
    ]) {
      await expectLater(local.salvarUrlApi(url), throwsA(isA<ArgumentError>()));
    }
    expect(await local.carregarUrlApi(), LocalService.urlPadrao);
  });

  test('CepService formata o endereço e valida o CEP', () async {
    final cliente = MockClient((requisicao) async {
      expect(
        requisicao.url.toString(),
        'https://viacep.com.br/ws/01001000/json/',
      );
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'cep': '01001-000',
            'logradouro': 'Praça da Sé',
            'bairro': 'Sé',
            'localidade': 'São Paulo',
            'uf': 'SP',
          }),
        ),
        200,
      );
    });
    final servico = CepService(cliente: cliente);
    expect(
      await servico.consultarCep('01001-000'),
      'Praça da Sé, Sé, São Paulo - SP (CEP 01001-000)',
    );
    expect(
      await servico.consultarCep('01001000'),
      'Praça da Sé, Sé, São Paulo - SP (CEP 01001-000)',
    );
    expect(() => servico.consultarCep('123'), throwsA(isA<CepException>()));
    expect(
      () => servico.consultarCep('abc01001000'),
      throwsA(isA<CepException>()),
    );
    expect(
      () => servico.consultarCep('01001 000'),
      throwsA(isA<CepException>()),
    );
    servico.fechar();
  });
}
