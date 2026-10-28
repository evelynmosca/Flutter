class Produto {
  final int? id;
  final String nome;
  final String descricao;
  final double preco;
  final String categoria;
  final String? imagemUrl;

  Produto({
    this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.categoria,
    this.imagemUrl,
  });

  double get descontoPercentual => 0;
  double get precoAtual => preco;

  factory Produto.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id']}');
    final preco = _lerNumero(json['preco'], 'preço');
    final desconto = _lerNumero(json['desconto_percentual'] ?? 0, 'desconto');
    final imagem = json['imagem_url']?.toString();

    if (desconto > 0) {
      return ProdutoPromocional(
        id: id,
        nome: json['nome']?.toString() ?? '',
        descricao: json['descricao']?.toString() ?? '',
        preco: preco,
        categoria: json['categoria']?.toString() ?? '',
        imagemUrl: imagem?.isEmpty == true ? null : imagem,
        descontoPercentual: desconto,
      );
    }

    return Produto(
      id: id,
      nome: json['nome']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      preco: preco,
      categoria: json['categoria']?.toString() ?? '',
      imagemUrl: imagem?.isEmpty == true ? null : imagem,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'categoria': categoria,
      'imagem_url': imagemUrl,
      'desconto_percentual': descontoPercentual,
    };
  }

  static double _lerNumero(dynamic valor, String campo) {
    if (valor is num) return valor.toDouble();
    final numero = double.tryParse('$valor'.replaceAll(',', '.'));
    if (numero == null) {
      throw FormatException('O $campo recebido da API é inválido.');
    }
    return numero;
  }
}

class ProdutoPromocional extends Produto {
  @override
  final double descontoPercentual;

  ProdutoPromocional({
    super.id,
    required super.nome,
    required super.descricao,
    required super.preco,
    required super.categoria,
    super.imagemUrl,
    required this.descontoPercentual,
  });

  @override
  double get precoAtual => preco * (1 - descontoPercentual / 100);
}
