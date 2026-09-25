class ItemCarrinho {
  final String nome;
  final double preco;
  final String urlImagem;
  int quantidade;

  ItemCarrinho({
    required this.nome,
    required this.preco,
    required this.urlImagem,
    this.quantidade = 1,
  });
}

final List<ItemCarrinho> produtosCarrinho = [];
