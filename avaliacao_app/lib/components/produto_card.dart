import 'package:flutter/material.dart';

import '../models/produto.dart';

class ProdutoCard extends StatelessWidget {
  const ProdutoCard({
    super.key,
    required this.produto,
    required this.onTap,
    this.acoes,
  });

  final Produto produto;
  final VoidCallback onTap;
  final Widget? acoes;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImagemProduto(url: produto.imagemUrl, tamanho: 88),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produto.nome,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          produto.categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          produto.descricao,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (produto.descontoPercentual > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE6E6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${produto.descontoPercentual.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Color(0xFFB42332),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    'R\$ ${produto.precoAtual.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: Color(0xFF4B27B8),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (acoes != null) ...[
                const Divider(height: 16),
                Align(alignment: Alignment.centerRight, child: acoes!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ImagemProduto extends StatelessWidget {
  const ImagemProduto({super.key, this.url, required this.tamanho});

  final String? url;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final imagemUrl = url?.trim() ?? '';
    final substituta = Container(
      width: tamanho,
      height: tamanho,
      color: const Color(0xFFECE8FA),
      child: Icon(
        Icons.shopping_basket,
        color: const Color(0xFF4B27B8),
        size: tamanho * 0.42,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imagemUrl.isEmpty
          ? substituta
          : Image.network(
              imagemUrl,
              width: tamanho,
              height: tamanho,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => substituta,
            ),
    );
  }
}
