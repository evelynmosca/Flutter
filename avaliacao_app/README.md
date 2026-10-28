# Mercadinho Genciana

Aplicativo Flutter para apresentar produtos e promoções de um comércio local e permitir o cadastro, a edição e a exclusão de produtos. O projeto atende à situação desafiadora “Do Zero ao App Integrado” da Avaliação Somativa de Programação para Dispositivos Móveis (PPDM).

## Tecnologias e onde os dados ficam

| Parte | Tecnologia | Local dos dados |
|---|---|---|
| Aplicativo Android e Web | Flutter e Dart | Dispositivo ou navegador |
| API de produtos | Python e SQLite | Computador que executa o backend, fora do APK |
| Comunicação REST | Pacote http | Rede entre aplicativo e API |
| Preferências simples | shared_preferences | Armazenamento local do aplicativo |
| Contato sensível | flutter_secure_storage | Armazenamento seguro do dispositivo |
| Consulta de CEP | ViaCEP | API pública adicional |

O backend é separado do aplicativo e precisa estar em execução para o CRUD. Os produtos persistem em `backend/mercadinho.db` no computador. A URL da API e os IDs de produtos favoritos ficam nas preferências do aplicativo; nome e telefone de contato usam `flutter_secure_storage` (persistência após reinício verificada no Android). A consulta ViaCEP não substitui a API de produtos.

O banco entregue contém produtos **demonstrativos**, cadastrados por POST para que o catálogo e as promoções apareçam ao iniciar. Os preços são exemplos fictícios; todos os registros podem ser editados ou excluídos no app.

## Organização

| Local | Responsabilidade |
|---|---|
| lib/main.dart | Inicialização, tema e navegação |
| lib/models/ | Modelos e conversão entre objetos Dart e JSON |
| lib/screens/ | Telas |
| lib/services/ | REST, preferências e armazenamento seguro |
| lib/components/ | Componentes reutilizados |
| backend/servidor.py | API REST e acesso ao banco SQLite |
| backend/popular_api.py | Preenche um catálogo vazio quando executado pelo aluno |
| backend/test_servidor.py | Testes HTTP e persistência da API |
| iniciar_api.ps1 | Inicia a API local e verifica se ela responde |
| .vscode/ | Inicia a API antes do app ao executar as configurações de depuração |
| test/ | Testes automatizados disponíveis |
| evidencias/ | Capturas e XMLs de verificações reais no Chrome e Android |
| entrega/ | Cópia do APK fora da pasta de build |
| CRITERIOS_AVALIACAO.md | Matriz de critérios e evidências |

## Telas

| Tela | Finalidade |
|---|---|
| Início | Identidade do mercadinho, apresentação, destaques e navegação |
| Produtos | GET, listagem, atualização, carregamento e estados vazio/erro |
| Detalhes | Informações completas e acesso à edição |
| Cadastro/Edição | Formulário validado, POST e PUT |
| Gerenciamento | Listagem, edição e DELETE com confirmação |
| Configurações | URL da API, contato local e consulta de CEP |

O modelo Produto representa id, nome, descrição, preço, categoria e imagem. ProdutoPromocional é uma subclasse usada quando há desconto percentual e calcula o preço atual. Os métodos de conversão JSON ligam esses objetos à API. Classes de tela e serviço têm responsabilidades próprias. Widgets compartilhados reduzem repetição. Listas e formulários usam rolagem para telas menores.

## Preparar o ambiente no Windows

1. Instale o Flutter SDK e inclua a pasta bin do SDK na variável Path. Verifique com flutter --version e flutter doctor -v.
2. Instale Android Studio com Android SDK, platform-tools e emulador. Na IDE, instale os plugins Flutter e Dart. Se usar VS Code, instale as extensões Flutter e Dart.
3. Resolva pendências mostradas por flutter doctor -v. Se necessário, configure o caminho do Android SDK e execute flutter doctor --android-licenses.
4. Instale Python 3 e confirme com python --version. O backend usa apenas bibliotecas da instalação padrão do Python.
5. Confirme que há um emulador ou dispositivo em flutter devices.

Comandos de verificação no PowerShell:

~~~powershell
Get-Command flutter, dart, python, code
code --list-extensions
Test-Path (Join-Path $env:LOCALAPPDATA 'Android\sdk\platform-tools\adb.exe')
flutter doctor -v
flutter devices
~~~

A instalação da IDE e dos plugins requer conferência no próprio computador; o código do app, sozinho, não comprova esse critério.

## Executar

No VS Code, abra a pasta do projeto e escolha **Mercadinho Genciana (Chrome + API)** ou **Mercadinho Genciana (emulador + API)** no menu Executar e Depurar. Essas configurações iniciam a API antes do Flutter. A tarefa também pode iniciar a API ao abrir a pasta; na primeira vez, o VS Code pode pedir para permitir tarefas automáticas. O botão de execução direta de `main.dart` não executa a tarefa antes do Flutter, então use uma das configurações acima ou o script do terminal.

Pelo terminal PowerShell, na pasta do projeto:

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\executar_app.ps1 -Dispositivo chrome
~~~

Para usar o emulador, troque `chrome` por `emulator-5554`. O `executar_app.ps1` prepara a API e depois executa o Flutter no dispositivo escolhido. O `iniciar_api.ps1` prepara os três produtos demonstrativos somente se o catálogo estiver vazio, verifica `/saude`, inicia o servidor Python em segundo plano quando necessário e mostra quantos produtos a API contém. Para popular manualmente um banco vazio, execute `python backend/popular_api.py`. Esse comando não modifica um catálogo que já tenha produtos.

Se preferir manter os logs do servidor visíveis, inicie a API em um terminal e o Flutter em outro:

~~~powershell
python backend/servidor.py
~~~

O app escolhe automaticamente a **URL base** para cada ambiente. Na tela Configurações é possível consultar, testar e alterar essa URL:

| Execução | URL |
|---|---|
| Emulador Android | http://10.0.2.2:8765 |
| Chrome ou Windows no mesmo computador | http://127.0.0.1:8765 |
| Celular físico | http://IP_DO_COMPUTADOR_NA_REDE:8765 |

O problema de tempo limite no Chrome ocorria porque `10.0.2.2` é um endereço exclusivo do emulador. A versão atual usa `127.0.0.1` no Chrome/Windows e corrige automaticamente esse endereço antigo se estiver salvo no navegador. A API foi testada no Chrome e no emulador com os mesmos três produtos.

Por padrão, o backend escuta somente em `127.0.0.1`, suficiente para este computador e para o emulador Android. Para **celular físico**, encerre a API local que estiver usando a porta 8765, conecte telefone e computador à mesma rede, inicie o servidor com o comando abaixo, use o IP do computador na tela Configurações e permita a porta 8765 no firewall, se necessário:

~~~powershell
python backend/servidor.py --host 0.0.0.0
~~~

Esse modo expõe a API à rede local, portanto use uma rede confiável e encerre o servidor depois da apresentação. No Android, localhost aponta para o próprio Android; o emulador usa 10.0.2.2 para chegar ao computador. Nenhum celular físico foi testado neste projeto.

O código Flutter não contém senha, chave privada ou credencial administrativa. A URL configurada não é credencial. Antes de disponibilizar a API publicamente, seria necessário acrescentar autenticação, controle de acesso e HTTPS.

### Rotas da API de produtos

| Método e rota | Função |
|---|---|
| GET /saude | Verificar se o servidor responde |
| GET /produtos | Listar produtos |
| GET /produtos/{id} | Consultar um produto |
| POST /produtos | Cadastrar produto |
| PUT /produtos/{id} | Atualizar produto |
| DELETE /produtos/{id} | Excluir produto |

O JSON de cadastro/edição contém nome, descricao, preco e categoria. Os campos imagem_url e desconto_percentual são opcionais. O backend valida os dados e grava em backend/mercadinho.db.

## CRUD e conferência manual

1. Inicie o backend, configure a URL e abra Produtos ou Gerenciamento. A listagem faz GET.
2. Abra Cadastro, preencha os campos obrigatórios e salve. O formulário faz POST; confira o novo produto na lista.
3. Abra um produto, altere um campo e salve. O formulário faz PUT; confira o novo valor na lista e nos detalhes.
4. Em Gerenciamento, peça a exclusão e confirme. A ação faz DELETE; confira que o registro saiu da lista.
5. Feche e reabra o aplicativo. Confira que as alterações de produtos persistem no backend e que a URL e o contato local continuam no dispositivo.
6. Desligue o backend temporariamente e atualize Produtos para conferir o tratamento de erro e a nova tentativa.

As requisições ocorrem de modo assíncrono, com estados de carregamento e mensagens compreensíveis.

## Entradas, processos e saídas

| Entrada | Processo | Saída |
|---|---|---|
| URL base | Salvar preferência e estabelecer comunicação | API selecionada ou erro de conexão |
| Dados de produto | Validar campos e preço, converter JSON e executar POST/PUT | Mensagem de resultado e listagem atualizada |
| Seleção de produto | Consultar/ler dados e apresentar atributos | Detalhes completos ou erro |
| Confirmação de exclusão | Executar DELETE | Registro removido ou mensagem de erro |
| Contato local | Gravar/ler no armazenamento seguro | Dados disponíveis após reinício |
| CEP | Validar e consultar ViaCEP | Endereço ou erro compreensível |

Os processos obrigatórios são navegação entre pelo menos três telas, lógica Dart, persistência local, GET, POST, PUT, DELETE, classes, subclasses e exportação/instalação do APK. Validação, atualização de lista, tratamento de erros e ViaCEP são processos adicionais.

### Características de Dart para explicar na avaliação

- Dart usa tipos como String, int, double e bool, além de null safety: id pode ser int? antes do cadastro e recebe um valor após a API criá-lo. Em Python, o tipo de uma variável é definido dinamicamente durante a execução; em Dart, a análise estática identifica várias incompatibilidades antes de rodar o app.
- A execução de rede usa Future, async e await. JavaScript também oferece Promises e await, mas Dart permite declarar explicitamente o tipo do resultado, por exemplo Future<Produto>. Enquanto a resposta chega, o aplicativo mostra carregamento sem bloquear a interface.
- Flutter, construído com Dart, usa StatelessWidget e StatefulWidget para descrever a interface; setState solicita uma nova apresentação quando o estado de uma tela muda.
- Construtores criam Produto e ProdutoPromocional; a subclasse sobrescreve o cálculo de precoAtual para aplicar o desconto.

Essas são comparações de uso, sem afirmar que os recursos são exclusivos de Dart. A explicação oral continua sendo responsabilidade do aluno.

## Gerar e instalar o APK

~~~powershell
flutter build apk --debug
flutter devices
flutter install --debug -d emulator-5554
~~~

Alternativa com adb, cujo executável não está no Path deste Windows:

~~~powershell
$adbMercadinho = Join-Path $env:LOCALAPPDATA 'Android\sdk\platform-tools\adb.exe'
& $adbMercadinho install -r 'build/app/outputs/flutter-apk/app-debug.apk'
& $adbMercadinho shell am start -n 'com.avaliacao.avaliacao_app/.MainActivity'
~~~

O APK fica em `build/app/outputs/flutter-apk/app-debug.apk`, com uma [cópia pronta para entrega](entrega/MercadinhoGenciana-debug.apk) fora da pasta de build. As duas cópias têm o mesmo SHA-256: `CE005AD1E825665E6FA8CED6B8E52CCA1A0E64BED845295E4760A93BD342634B`. O build e a instalação passaram no emulador em 28/10/2026. A API Python precisa estar ativa durante o uso do APK.

## Decisões, alternativas e problemas

| Etapa | Registro |
|---|---|
| Análise | O PDF exige dados sensíveis locais, banco externo ao app, quatro verbos REST, ao menos três telas, POO e APK instalado. Os ZIPs anteriores orientam a estrutura simples do Flutter. |
| Planejamento | Mercadinho escolhido por permitir catálogo, promoções e CRUD em telas úteis. |
| API | Backend próprio com SQLite escolhido para persistir POST, PUT e DELETE; APIs de demonstração sem persistência foram descartadas. |
| Dados locais | URL e favoritos em preferências; nome e telefone em armazenamento seguro. SQLite no backend não substitui dados locais do dispositivo. |
| Interface | Telas por tarefa, com widgets compartilhados onde reduzem repetição. |
| Integração adicional | ViaCEP escolhido para fornecer endereço sem interferir no CRUD. |

Problemas e soluções registrados: o emulador acessa o computador por `10.0.2.2`, enquanto Chrome/Windows precisam de `127.0.0.1`; o endereço único anterior gerava tempo limite no Chrome. `LocalService` agora escolhe a URL por plataforma e migra o endereço antigo salvo no navegador. Uma API demonstrativa não comprovaria persistência, então o backend usa SQLite. Para evitar esquecer o servidor desligado, o VS Code executa `iniciar_api.ps1` antes de abrir o app.

## Validação realizada em 28/10/2026

Comandos para repetir os testes de código e build:

~~~powershell
flutter pub get
flutter analyze
flutter test
python -m unittest discover -s backend -p "test_*.py" -v
flutter build web
flutter build apk --debug
flutter install --debug -d emulator-5554
~~~

| Verificação | Resultado executado |
|---|---|
| Dependências e análise | `flutter pub get` passou; `flutter analyze` terminou sem problemas. |
| Testes Flutter | `flutter test`: **7/7** testes de modelo, serviço e formulário; a escolha da URL por plataforma e a migração da URL antiga foram testadas. |
| Backend | **3/3** testes HTTP reais, incluindo POST, PUT, DELETE e persistência SQLite após reiniciar o servidor. |
| API local | `iniciar_api.ps1` reiniciou a API; GET retornou os três produtos demonstrativos em `backend/mercadinho.db`. |
| Chrome | `flutter build web` passou; a [captura Web](evidencias/chrome_catalogo.png) mostra os três produtos e promoções carregados da API, sem tempo limite. |
| Android | `flutter build apk --debug` e `flutter install --debug -d emulator-5554` passaram; a [captura Android](evidencias/android_catalogo.png) e o [XML](evidencias/android_catalogo.xml) mostram os três produtos. |
| Nome do aplicativo | O APK atualizado abriu no emulador com [Mercadinho Genciana na tela inicial](evidencias/genciana_android.png), confirmado também no [XML](evidencias/genciana_android.xml); o build Web contém o mesmo título. |
| POST pela interface | Produto de teste criado no emulador por formulário, confirmado por GET no backend e no [XML da tela](evidencias/produto_criado.xml) com preço R$ 12,50. |
| PUT pela interface | Preço do mesmo produto alterado para R$ 14,00, confirmado por GET `/produtos/11` e no [XML da tela](evidencias/produto_editado.xml). |
| DELETE pela interface | Gerenciamento pediu confirmação e excluiu o produto; GET `/produtos/11` retornou 404, restaram três produtos e o [XML da tela](evidencias/produto_excluido.xml) registrou o sucesso. |
| Persistência local e remota | Após encerrar e reabrir o processo Android, a [captura](evidencias/reinicio_android.png) e o [XML](evidencias/reinicio_android.xml) mostram o contato fictício e os três produtos; o [XML das Configurações](evidencias/contato_apos_reinicio.xml) confirma nome e telefone recuperados do armazenamento seguro. |
| ViaCEP real | O [resultado no emulador](evidencias/cep_resultado.png) e o [XML](evidencias/cep_resultado.xml) mostram o endereço obtido para 01001-000. |
| Layout | O formulário passou em 320 × 640 e 800 × 1000 no teste de widget; houve inspeção visual no Chrome e no emulador. As demais telas não foram revisadas visualmente em tablet. |

A pasta `integration_test` e sua dependência foram removidas porque não são necessárias para executar o aplicativo. O fluxo real de CRUD foi conferido manualmente no emulador e os testes automáticos restantes ficam em `test/` e `backend/test_servidor.py`. Ao terminar a conferência, o produto temporário foi excluído e os dados locais fictícios foram limpos do emulador; os produtos demonstrativos permanecem no banco.

O `flutter doctor -v` encontrou Flutter 3.41.9, Dart 3.12.2, Android SDK 36.1.0 e o emulador Android API 37. Ainda há avisos sobre licenças Android opcionais e componentes do Visual Studio para aplicativos Windows. Eles não impediram o build e a instalação Android. A versão Web foi testada no Chrome; um executável Windows e um celular físico não foram testados.

Veja [CRITERIOS_AVALIACAO.md](CRITERIOS_AVALIACAO.md) para a matriz completa e o checklist de evidências pessoais.
