"""Adiciona produtos demonstrativos somente quando o catálogo está vazio."""

from servidor import ARQUIVO_BANCO, BancoProdutos, validar_produto


PRODUTOS_EXEMPLO = [
    {
        "nome": "Arroz branco 5 kg",
        "descricao": "Pacote de arroz branco tipo 1 para o dia a dia.",
        "preco": 24.90,
        "categoria": "Mercearia",
        "desconto_percentual": 10,
    },
    {
        "nome": "Leite integral 1 L",
        "descricao": "Leite integral em embalagem longa vida de 1 litro.",
        "preco": 5.49,
        "categoria": "Laticínios",
    },
    {
        "nome": "Banana prata 1 kg",
        "descricao": "Banana prata vendida por quilo.",
        "preco": 6.99,
        "categoria": "Hortifruti",
        "desconto_percentual": 15,
    },
]


def popular():
    banco = BancoProdutos(ARQUIVO_BANCO)
    if banco.listar():
        print("O catálogo já tem produtos; nenhum registro foi alterado.")
        return

    for dados in PRODUTOS_EXEMPLO:
        banco.cadastrar(validar_produto(dados))
    print(f"{len(PRODUTOS_EXEMPLO)} produtos demonstrativos cadastrados.")


if __name__ == "__main__":
    popular()
