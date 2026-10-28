"""API REST simples do Mercadinho Genciana, com dados persistidos em SQLite."""

import argparse
import json
import math
import re
import sqlite3
from contextlib import closing
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse, urlsplit


ARQUIVO_BANCO = Path(__file__).with_name("mercadinho.db")
CAMPOS_OBRIGATORIOS = {"nome", "descricao", "preco", "categoria"}
CAMPOS_OPCIONAIS = {"imagem_url", "desconto_percentual"}


class ErroValidacao(Exception):
    """Representa um dado inválido recebido na requisição."""


def validar_produto(dados):
    """Confere e normaliza os campos enviados no cadastro ou edição."""
    if not isinstance(dados, dict):
        raise ErroValidacao("Envie um objeto JSON com os dados do produto.")

    faltando = CAMPOS_OBRIGATORIOS - dados.keys()
    if faltando:
        raise ErroValidacao(f"Campo obrigatório ausente: {sorted(faltando)[0]}.")

    desconhecidos = dados.keys() - CAMPOS_OBRIGATORIOS - CAMPOS_OPCIONAIS
    if desconhecidos:
        raise ErroValidacao(f"Campo desconhecido: {sorted(desconhecidos)[0]}.")

    produto = {}
    for campo in ("nome", "descricao", "categoria"):
        valor = dados[campo]
        if not isinstance(valor, str) or not valor.strip():
            raise ErroValidacao(f"O campo {campo} deve conter um texto.")
        produto[campo] = valor.strip()

    preco = dados["preco"]
    if (
        isinstance(preco, bool)
        or not isinstance(preco, (int, float))
        or not math.isfinite(preco)
        or preco <= 0
    ):
        raise ErroValidacao("O preço deve ser um número maior que zero.")
    produto["preco"] = float(preco)

    desconto = dados.get("desconto_percentual", 0)
    if (
        isinstance(desconto, bool)
        or not isinstance(desconto, (int, float))
        or not math.isfinite(desconto)
        or not 0 <= desconto <= 90
    ):
        raise ErroValidacao("O desconto deve ser um número entre 0 e 90.")
    produto["desconto_percentual"] = float(desconto)

    imagem = dados.get("imagem_url")
    if imagem is not None:
        if not isinstance(imagem, str):
            raise ErroValidacao("A imagem deve ser uma URL ou estar vazia.")
        imagem = imagem.strip() or None
        if imagem:
            endereco = urlparse(imagem)
            if endereco.scheme not in ("http", "https") or not endereco.netloc:
                raise ErroValidacao("A imagem deve usar uma URL HTTP ou HTTPS válida.")
    produto["imagem_url"] = imagem

    return produto


class BancoProdutos:
    """Armazena os produtos em um arquivo SQLite fora do aplicativo Flutter."""

    def __init__(self, caminho):
        self.caminho = str(caminho)
        with closing(self._conectar()) as conexao:
            with conexao:
                conexao.execute(
                    """
                    CREATE TABLE IF NOT EXISTS produtos (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        nome TEXT NOT NULL,
                        descricao TEXT NOT NULL,
                        preco REAL NOT NULL CHECK (preco > 0),
                        categoria TEXT NOT NULL,
                        imagem_url TEXT,
                        desconto_percentual REAL NOT NULL DEFAULT 0
                            CHECK (desconto_percentual BETWEEN 0 AND 90)
                    )
                    """
                )

    def _conectar(self):
        conexao = sqlite3.connect(self.caminho, timeout=15)
        conexao.row_factory = sqlite3.Row
        return conexao

    def listar(self):
        with closing(self._conectar()) as conexao:
            registros = conexao.execute(
                "SELECT * FROM produtos ORDER BY id DESC"
            ).fetchall()
            return [dict(registro) for registro in registros]

    def buscar(self, produto_id):
        with closing(self._conectar()) as conexao:
            registro = conexao.execute(
                "SELECT * FROM produtos WHERE id = ?", (produto_id,)
            ).fetchone()
            return dict(registro) if registro else None

    def cadastrar(self, produto):
        with closing(self._conectar()) as conexao:
            with conexao:
                cursor = conexao.execute(
                    """
                    INSERT INTO produtos
                        (nome, descricao, preco, categoria, imagem_url,
                         desconto_percentual)
                    VALUES (:nome, :descricao, :preco, :categoria, :imagem_url,
                            :desconto_percentual)
                    """,
                    produto,
                )
                registro = conexao.execute(
                    "SELECT * FROM produtos WHERE id = ?", (cursor.lastrowid,)
                ).fetchone()
                return dict(registro)

    def atualizar(self, produto_id, produto):
        with closing(self._conectar()) as conexao:
            with conexao:
                cursor = conexao.execute(
                    """
                    UPDATE produtos SET
                        nome = :nome,
                        descricao = :descricao,
                        preco = :preco,
                        categoria = :categoria,
                        imagem_url = :imagem_url,
                        desconto_percentual = :desconto_percentual
                    WHERE id = :id
                    """,
                    {**produto, "id": produto_id},
                )
                if cursor.rowcount == 0:
                    return None
                registro = conexao.execute(
                    "SELECT * FROM produtos WHERE id = ?", (produto_id,)
                ).fetchone()
                return dict(registro)

    def excluir(self, produto_id):
        with closing(self._conectar()) as conexao:
            with conexao:
                cursor = conexao.execute(
                    "DELETE FROM produtos WHERE id = ?", (produto_id,)
                )
                return cursor.rowcount > 0


class ServidorMercadinho(ThreadingHTTPServer):
    """Servidor HTTP que mantém a referência ao banco de dados."""

    daemon_threads = True

    def __init__(self, endereco, caminho_banco=ARQUIVO_BANCO):
        self.banco = BancoProdutos(caminho_banco)
        super().__init__(endereco, RequisicaoMercadinho)


class RequisicaoMercadinho(BaseHTTPRequestHandler):
    """Define os endpoints HTTP consumidos pelo aplicativo."""

    def _caminho(self):
        return urlsplit(self.path).path.rstrip("/") or "/"

    def _produto_id(self):
        resultado = re.fullmatch(r"/produtos/([1-9][0-9]*)", self._caminho())
        return int(resultado.group(1)) if resultado else None

    def _responder(self, status, dados=None):
        corpo = b"" if dados is None else json.dumps(
            dados, ensure_ascii=False, allow_nan=False
        ).encode("utf-8")
        self.send_response(status)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        if dados is not None:
            self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(corpo)))
        self.end_headers()
        if corpo:
            self.wfile.write(corpo)

    def _erro(self, status, mensagem):
        self._responder(status, {"erro": mensagem})

    def _ler_json(self):
        try:
            tamanho = int(self.headers.get("Content-Length", "0"))
        except ValueError as erro:
            raise ErroValidacao("Tamanho da requisição inválido.") from erro
        if tamanho <= 0 or tamanho > 1024 * 1024:
            raise ErroValidacao("Envie um JSON de até 1 MB.")
        try:
            return json.loads(self.rfile.read(tamanho).decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as erro:
            raise ErroValidacao("O corpo da requisição não é um JSON válido.") from erro

    def _atender(self, funcao):
        try:
            funcao()
        except ErroValidacao as erro:
            self._erro(400, str(erro))
        except sqlite3.Error:
            self._erro(500, "Não foi possível acessar o banco de dados.")

    def do_OPTIONS(self):
        self._responder(204)

    def do_GET(self):
        self._atender(self._get)

    def _get(self):
        caminho = self._caminho()
        if caminho == "/saude":
            self._responder(200, {"status": "ok"})
        elif caminho == "/produtos":
            self._responder(200, self.server.banco.listar())
        elif (produto_id := self._produto_id()) is not None:
            produto = self.server.banco.buscar(produto_id)
            if produto is None:
                self._erro(404, "Produto não encontrado.")
            else:
                self._responder(200, produto)
        else:
            self._erro(404, "Endereço não encontrado.")

    def do_POST(self):
        self._atender(self._post)

    def _post(self):
        if self._caminho() != "/produtos":
            self._erro(404, "Endereço não encontrado.")
            return
        produto = validar_produto(self._ler_json())
        self._responder(201, self.server.banco.cadastrar(produto))

    def do_PUT(self):
        self._atender(self._put)

    def _put(self):
        produto_id = self._produto_id()
        if produto_id is None:
            self._erro(404, "Endereço não encontrado.")
            return
        produto = validar_produto(self._ler_json())
        atualizado = self.server.banco.atualizar(produto_id, produto)
        if atualizado is None:
            self._erro(404, "Produto não encontrado.")
        else:
            self._responder(200, atualizado)

    def do_DELETE(self):
        self._atender(self._delete)

    def _delete(self):
        produto_id = self._produto_id()
        if produto_id is None:
            self._erro(404, "Endereço não encontrado.")
        elif self.server.banco.excluir(produto_id):
            self._responder(204)
        else:
            self._erro(404, "Produto não encontrado.")


def iniciar():
    analisador = argparse.ArgumentParser(description="API REST do Mercadinho Genciana")
    analisador.add_argument("--host", default="127.0.0.1", help="Endereço de rede")
    analisador.add_argument("--port", type=int, default=8765, help="Porta HTTP")
    analisador.add_argument(
        "--db", type=Path, default=ARQUIVO_BANCO, help="Caminho do banco SQLite"
    )
    argumentos = analisador.parse_args()
    servidor = ServidorMercadinho((argumentos.host, argumentos.port), argumentos.db)
    print(f"API disponível em http://{argumentos.host}:{argumentos.port}", flush=True)
    try:
        servidor.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        servidor.server_close()


if __name__ == "__main__":
    iniciar()
