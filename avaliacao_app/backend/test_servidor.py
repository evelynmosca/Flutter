"""Testes HTTP da API e da persistência do banco SQLite."""

import json
import tempfile
import threading
import unittest
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from servidor import ServidorMercadinho


class TesteServidorMercadinho(unittest.TestCase):
    def setUp(self):
        self.pasta = tempfile.TemporaryDirectory()
        self.banco = Path(self.pasta.name) / "teste.db"
        self._iniciar_servidor()

    def tearDown(self):
        self._parar_servidor()
        self.pasta.cleanup()

    def _iniciar_servidor(self):
        self.servidor = ServidorMercadinho(("127.0.0.1", 0), self.banco)
        self.thread = threading.Thread(target=self.servidor.serve_forever, daemon=True)
        self.thread.start()
        self.url = f"http://127.0.0.1:{self.servidor.server_port}"

    def _parar_servidor(self):
        self.servidor.shutdown()
        self.servidor.server_close()
        self.thread.join(timeout=5)

    def requisicao(self, metodo, caminho, dados=None, corpo=None):
        if dados is not None:
            corpo = json.dumps(dados).encode("utf-8")
        requisicao = Request(
            self.url + caminho,
            data=corpo,
            method=metodo,
            headers={"Content-Type": "application/json"},
        )
        try:
            resposta = urlopen(requisicao, timeout=5)
        except HTTPError as erro:
            resposta = erro
        with resposta:
            conteudo = resposta.read()
            return resposta.status, json.loads(conteudo) if conteudo else None

    def produto_exemplo(self):
        return {
            "nome": "Arroz",
            "descricao": "Pacote de 1 kg",
            "preco": 7.5,
            "categoria": "Mercearia",
            "imagem_url": None,
            "desconto_percentual": 10,
        }

    def test_crud_e_persistencia_apos_reiniciar_servidor(self):
        self.assertEqual(self.requisicao("GET", "/saude"), (200, {"status": "ok"}))
        self.assertEqual(self.requisicao("GET", "/produtos"), (200, []))

        status, criado = self.requisicao("POST", "/produtos", self.produto_exemplo())
        self.assertEqual(status, 201)
        self.assertIsInstance(criado["id"], int)
        self.assertEqual(criado["nome"], "Arroz")
        produto_id = criado["id"]

        status, lista = self.requisicao("GET", "/produtos")
        self.assertEqual(status, 200)
        self.assertEqual(lista, [criado])
        self.assertEqual(self.requisicao("GET", f"/produtos/{produto_id}"), (200, criado))

        editado = {**self.produto_exemplo(), "nome": "Arroz integral", "preco": 8.25}
        status, atualizado = self.requisicao("PUT", f"/produtos/{produto_id}", editado)
        self.assertEqual(status, 200)
        self.assertEqual(atualizado["nome"], "Arroz integral")
        self.assertEqual(atualizado["preco"], 8.25)

        self._parar_servidor()
        self._iniciar_servidor()
        self.assertEqual(
            self.requisicao("GET", f"/produtos/{produto_id}"), (200, atualizado)
        )
        self.assertEqual(self.requisicao("GET", "/produtos"), (200, [atualizado]))

        self.assertEqual(self.requisicao("DELETE", f"/produtos/{produto_id}"), (204, None))
        self._parar_servidor()
        self._iniciar_servidor()
        self.assertEqual(self.requisicao("GET", "/produtos"), (200, []))
        self.assertEqual(self.requisicao("GET", f"/produtos/{produto_id}")[0], 404)

    def test_validacao_erros_e_estado_vazio(self):
        exemplo = self.produto_exemplo()
        casos = [
            ({**exemplo, "nome": "  "}, "nome"),
            ({**exemplo, "preco": 0}, "preço"),
            ({**exemplo, "preco": True}, "preço"),
            ({**exemplo, "desconto_percentual": 91}, "desconto"),
            ({**exemplo, "imagem_url": "arquivo.png"}, "imagem"),
            ({"nome": "Incompleto"}, "obrigatório"),
        ]
        for dados, trecho in casos:
            with self.subTest(dados=dados):
                status, resposta = self.requisicao("POST", "/produtos", dados)
                self.assertEqual(status, 400)
                self.assertIn(trecho, resposta["erro"])

        status, resposta = self.requisicao("POST", "/produtos", corpo=b"{invalido")
        self.assertEqual(status, 400)
        self.assertIn("JSON válido", resposta["erro"])
        self.assertEqual(self.requisicao("GET", "/produtos"), (200, []))
        self.assertEqual(self.requisicao("GET", "/produtos/999")[0], 404)
        self.assertEqual(self.requisicao("PUT", "/produtos/999", exemplo)[0], 404)
        self.assertEqual(self.requisicao("DELETE", "/produtos/999")[0], 404)
        self.assertEqual(self.requisicao("GET", "/desconhecido")[0], 404)

    def test_campos_opcionais_e_cors(self):
        exemplo = self.produto_exemplo()
        del exemplo["imagem_url"]
        del exemplo["desconto_percentual"]
        status, criado = self.requisicao("POST", "/produtos", exemplo)
        self.assertEqual(status, 201)
        self.assertIsNone(criado["imagem_url"])
        self.assertEqual(criado["desconto_percentual"], 0)

        requisicao = Request(self.url + "/produtos", method="OPTIONS")
        with urlopen(requisicao, timeout=5) as resposta:
            self.assertEqual(resposta.status, 204)
            self.assertEqual(resposta.headers["Access-Control-Allow-Origin"], "*")


if __name__ == "__main__":
    unittest.main()
