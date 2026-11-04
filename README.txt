Compendium5e v0.1 - pacote de teste

1. Instale o Firecast SDK 3 e deixe o comando rdk disponivel.
2. Execute install.bat para tentar compilar e instalar (rdk i).
3. Ou execute compile.bat para somente compilar (rdk c).
4. O objetivo desta versao e validar carregamento, busca, filtros e detalhes.

Observacao: o module.xml foi montado como primeira implementacao a partir da estrutura do SDK e deve ser validado no rdk real. Se o rdk acusar erro de schema, envie a mensagem completa para ajuste.

IMPORTADOR V0.2
---------------
Execute:
  importar.bat "C:\caminho\para\5etools\data"
Depois compile novamente com:
  rdk c

Categorias iniciais: magias, especies/racas, classes, feats, itens, backgrounds e condicoes.
O importador trabalha somente com arquivos locais e sobrescreve data/index.lua e data/entries.lua.

ATUALIZADOR AUTOMATICO V0.2.1
-----------------------------
1. Execute atualizar_dados.bat com internet ativa.
2. O script baixa a distribuicao publica atual do repositorio 5etools-src.
3. Extrai temporariamente, executa o importador e gera data/index.lua e data/entries.lua.
4. Os arquivos temporarios sao descartados.
5. Execute rdk c ou rdk i.

Leia LICENCAS-E-AVISOS.txt antes de distribuir o plugin.

V0.3.0 - LISTA CLICAVEL E FILTRO POR LIVRO
------------------------------------------
- Resultados agora usam recordList selecionavel.
- Clique em um resultado para abrir os detalhes.
- O filtro Livro e preenchido automaticamente a partir das fontes presentes em data/index.lua.
- Foram removidos os botoes Anterior/Proximo.

V0.4.0 BROWSER
--------------
Menu lateral para navegacao manual: Tudo, Magias, Especies, Classes, Feats,
Backgrounds, Itens, Itens Magicos, Criaturas e Condicoes.
Uma categoria lista seus registros mesmo com busca vazia.
Itens Magicos ganham filtro de raridade. Criaturas ganham filtro de CR.
Livro e edicao continuam disponiveis.
O atualizador/importador agora coleta bestiary/*.json e separa itens magicos dos mundanos.

V0.4.1 HOTFIX DE DESEMPENHO
---------------------------
- Nao enumera toda a base ao abrir o Compendio.
- O usuario precisa escolher uma categoria primeiro.
- No maximo 50 paineis de resultado sao criados por busca.
- O contador ainda informa quantos registros satisfazem os filtros.
Esta versao e uma mitigacao. A proxima arquitetura deve paginar e segmentar os dados.

V0.5.0 - BROWSER COM ABAS
-------------------------
- Navegacao principal por tabControl/tab.
- Ao trocar de aba: limpa pesquisa, selecao, resultados e painel de detalhes.
- Paginacao manual de 30 registros por pagina em todas as secoes.
- Busca Global permanece separada das abas de material.
- Separador dourado nos cards para aproximar visualmente o compendio da ficha.

OBSERVACAO SOBRE AS IMAGENS DO REPOSITORIO
O repositorio Att-ficha-player possui pastas frames/ e images/, mas o ambiente de montagem
nao permitiu baixar os binarios do GitHub. Por isso esta compilacao nao inclui copias
inventadas desses assets. Eles podem ser incorporados numa revisao visual quando os
arquivos forem disponibilizados localmente junto ao projeto.

V0.5.1 - LIMPEZA EXPLICITA
--------------------------
- Adicionado botao Limpar ao lado de Buscar.
- Limpar redefine texto, resultado selecionado, filtros, pagina e painel de detalhes.
- Troca de setor chama a mesma rotina de limpeza para evitar estado residual.

V0.5.2 - MODO ESTAVEL SEM NODEDATABASE
--------------------------------------
- Remove tabControl para eliminar sobreposicao/interceptacao da interface.
- Abas visuais agora sao botoes fixos no topo.
- Remove recordList e searchResults do NodeDatabase.
- Usa 15 botoes fixos e reutilizaveis para resultados; nenhuma pesquisa e persistida.
- Trocar de secao limpa imediatamente texto, detalhes, pagina e linhas.
- data/entries.lua e carregado somente quando o usuario clica em um resultado.

V0.6.0 - MAGIAS, CRIATURAS, SUBCLASSES E FEATURES
--------------------------------------------------
- Magias: indice preserva nivel, escola, ritual, concentracao e classes; UI filtra nivel/escola/ritual/concentracao.
- Criaturas: detalhes importados em secoes de estatisticas, tracos, conjuracao, acoes, bonus, reacoes, lendarias e miticas quando presentes.
- Classes: importador coleta subclass, classFeature e subclassFeature dos arquivos class/*.json.
- Browser adiciona secoes Subclasses e Features sem voltar a usar NodeDatabase para resultados.

V0.6.1
------
- Magias: filtro por Classe.
- Criaturas: filtros Tipo/Tamanho e botoes internos Tudo/Stats/Tracos/Acoes/Bonus/Reacoes/Lendarias.
- Classes: subclasses e class/subclass features sao agregadas no detalhe da classe; removidas como secoes principais do navegador.

V0.7.0 - CONTEUDO EXTRA + GRID
------------------------------
- Importacao local adicional: optionalfeatures, charcreationoptions, actions, rewards, objects,
  traps/hazards, psionics, deities, languages, vehicles e bastions quando presentes.
- Barra de acesso rapido para conteudos extras.
- Ajustes de largura/espacamento dos filtros para reduzir sobreposicoes.
- Calculadora de raio em grid: 1 square = 1,5 m e contagem por centro do quadrado.
- Mantida arquitetura sem recordList/NodeDatabase temporario.

V0.7.1 - CORRECAO DE LAYOUT E FILTROS
-------------------------------------
- Filtros comuns, de magia, criatura e item magico foram separados em linhas contextuais.
- Filtros aplicam automaticamente no onChange; Buscar continua disponivel para texto.
- Barra Extras aparece apenas nas categorias extras.
- Corrigida condicao tautologica ao associar features de classes.
- Subclass features agora usam subclassKey explicita, evitando associacao por substring do ID.

V0.7.2 - FILTROS E HOMEBREW LOCAL
---------------------------------
- Escolas de magia sao exibidas por nome, mantendo o codigo original em schoolCode.
- Classes de magia usam generated/gendata-spell-source-lookup.json quando disponivel e caem no campo embutido como fallback.
- Novo --homebrew PASTA no importador; a opcao pode ser repetida para varias pastas locais.
- Entradas importadas dessas pastas recebem origin=homebrew.
- LOOT_ARCHITECTURE.md documenta o desenho do gerador sem ainda embutir regras/tabelas no LuaForm.

V0.8.0 - IMPORTADOR AUTOMATICO LOCAL DE HOMEBREW
-------------------------------------------------
Uso simples no Windows:
  importar_homebrew_auto.bat "C:\5etools\data" "C:\MeuHomebrew"

O importador:
1. procura recursivamente *.json;
2. valida se o JSON possui categorias reconhecidas do 5etools;
3. ignora arquivos invalidos/irrelevantes sem interromper toda a importacao;
4. cria homebrew_manifest.json com aceitos, ignorados e totais por tipo;
5. executa o importador principal com a pasta homebrew;
6. nunca baixa conteudo automaticamente da internet.

V0.9.1 - BARRA DE FERRAMENTAS E CHECKBOXES
------------------------------------------
- Loot, Favoritos e Areas movidos para uma barra secundaria dedicada, sem depender da largura da barra principal.
- Tipo de item usa checkboxes Arma/Armadura/Equipamento/Outros; marcacoes combinam por OR.
- Raridade de item magico usa checkboxes Comum/Incomum/Raro/Muito raro/Lendario/Artefato; marcacoes combinam por OR.
- Sintonizacao permanece seletor Todas/Sim/Nao.

V0.9.2 - ATUALIZADOR RESILIENTE
-------------------------------
- Tenta dois endpoints do mesmo repositorio publico.
- Usa timeout e User-Agent explicitos.
- Distingue falha de rede/DNS e preserva os dados atuais.
- Oferece modo offline/local:
  atualizar_dados.bat "C:\caminho\para\5etools\data"
- Valida o ZIP e a pasta data antes de substituir os arquivos gerados.

V1.0.0 - HOARD + VALORES 2024 + CRAFTING
----------------------------------------
- Loot permite Individual ou Hoard por CR/edicao, usando secoes correspondentes de loot.json.
- Hoard converte moedas, gemas, objetos de arte e referencias a tabelas de itens magicos quando presentes.
- Itens magicos recebem valor padrao, custo e dias de crafting 2024 derivados da raridade; consumiveis detectados recebem metade quando aplicavel.
- Detalhes dos itens magicos exibem raridade, sintonizacao, valor 2024 e crafting.
- Botao Calcular crafting abre ferramenta integrada e divide o tempo pelo numero de trabalhadores.

V1.0.1 HOTFIX
-------------
- Corrige strings multilinha invalidas no Lua da calculadora de crafting.
- Textos usam escapes \\n dentro das strings, evitando "unfinished string" no carregamento do form.

V1.1.0 - CRAFTING TAB + LOOT RESOLVIDO
--------------------------------------
- Crafting agora aparece como aba/ferramenta principal ao lado de Loot.
- O botao no item magico continua integrado e abre a mesma aba ja preenchida.
- import_loot.py importa tambem as tabelas reais de itens magicos A-I do loot.json.
- Hoards 2014 agora rolam quantidade e d100 dentro da tabela indicada, retornando o nome real do item.
- Loot 2024 randomByLevel agora retorna item magico real dentre itens importados, filtrado por faixa de raridade/CR pelo motor local.

V1.2.0 - MOTOR DE TABELAS
-------------------------
- Crafting e Loot sao abas separadas e visiveis na barra secundaria.
- Nova aba Tabelas importa e rola tables.json.
- table_engine.lua centraliza dados, intervalos e formatacao para Loot e tabelas comuns.
- Corrigido o escopo local de calculateCrafting.
- MAGIC_TABLES_PLAN.md documenta a resolucao completa de referencias, item groups e magic variants.

V1.3.0 - RESOLVEDOR UID/ITEMGROUP + VALIDACAO
---------------------------------------------
- Gera data/loot_resolver.lua indexado por name|source.
- Resolve referencias diretas de item e itemGroup em resultados magicos antes de exibir Loot.
- Resultados concretos tentam mostrar raridade, sintonizacao e valor 2024 do indice.
- Gera data/loot_validation.json para grupos/referencias e data/tables_validation.json para lacunas/sobreposicoes 1-100.

V1.4.0 - ATRIBUTOS + MAGIC VARIANTS + LAYOUT
---------------------------------------------
- Nova aba Atributos: Standard Array, referencia Point Buy 27 e rolador configuravel d6 com descarte dos menores.
- Resolvedor expande magicvariants sobre itens-base com namePrefix/nameSuffix/nameRemove e requisitos conservadores.
- Barra Extras ampliada; botoes e rotulos de Livro/Edicao/Origem receberam mais largura para evitar truncamento.
- Calculadora de CR permanece planejada para a proxima etapa.

V1.5.0 - REFERENCIAS INDEPENDENTES
---------------------------------
- Removida a aba/botao Extras e o painel condicional pnlExtrasBar.
- Opcoes e Features, Backgrounds, Opcoes de Personagem, Acoes, Recompensas, Objetos, Armadilhas e Perigos, Psionicos e Veiculos agora sao acessos independentes permanentes em duas linhas de Referencias.
- CR foi reservado diretamente na barra Ferramentas, ao lado de Atributos; o calculo completo fica para a proxima etapa.

V1.6.0 - CALCULADORA DE CR E TESTES DE PAINEIS
----------------------------------------------
- Calculadora de CR 2014 implementada: CR defensivo por PV/CA, ofensivo por dano/ataque ou CD, e media final.
- Larguras das barras Referencias e Ferramentas ajustadas para manter palavras completas em 710 px.
- Teste estrutural verifica botoes, funcoes, paineis, controles e exclusividade de visibilidade.

V1.7.0 - ENCONTROS 2024 + TABELAS + CRAFTING COMUM
--------------------------------------------------
- Nova aba Encontros filtra tabelas importadas do DMG 2024 (XDMG) com nome de encounter e rola pelo table_engine.
- Aba Tabelas ganhou busca por nome e filtro por livro/source.
- Loot tenta resolver gemas e objetos de arte em resultados concretos via tables.lua.
- Botao Calcular crafting aparece apenas quando o resultado aberto tem crafting suportado.
- Itens comuns com preco numerico recebem crafting 2024: materiais = metade do preco; tempo = preco GP / 10, arredondado para cima, com jornada de 8h; assistentes dividem o tempo.

V1.7.2 HOTFIX LUA DEFINITIVO
----------------------------
- Reescreve a saida da calculadora de CR usando table.concat e string.char(10).
- Remove todas as barras invertidas da linha que o parser do Firecast rejeitava.
- Divide a expressao aninhada de ataque/CD em instrucoes Lua simples.

V1.8.0 - NAVEGACAO UNIFICADA
----------------------------
- Referencias agora fazem parte do bloco Compendio, logo abaixo das categorias principais.
- Ferramentas ficam exclusivamente no bloco Ferramentas.
- Ferramentas foram divididas em duas linhas para evitar truncamento em janelas estreitas.

V1.8.1 - LIMPEZA DE TRANSICAO ENTRE ABAS
----------------------------------------
- Adiciona hideAllPanels() como reset central de paineis e subpaineis.
- Filtros de magia/criatura/item, raridade, tabs de criatura e botao de crafting agora sao ocultados antes de abrir qualquer secao.
- Corrige chooseSection para limpar primeiro e somente depois tornar o Browser visivel.

V1.8.2 - REFERENCIAS CONTEXTUAIS
--------------------------------
- Opcoes/Backgrounds/Personagem/Acoes/Recompensas/Objetos/Perigos/Psionicos/Veiculos foram agrupados em pnlReferenceNav.
- O bloco de referencias fica oculto por padrao e so aparece ao navegar dentro dessas categorias, evitando ocupar todas as ferramentas e telas.

V2.0.0 - ENCOUNTER BUILDER 2024 + AUDITORIA
-------------------------------------------
- Encounter Builder 2024 com budgets Baixo/Moderado/Alto por personagem, niveis 1-20 e grupos mistos.
- Monstros podem ser adicionados por CR/XP; o painel mostra XP total, dificuldade e saldo ate Alto.
- Encontros aleatorios sao importados de encounters.json, separados de tables.json.
- Corrigida a conversao de intervalos d100 terminados em 00 (por exemplo 91-00 = 91-100).
- Seletores exibem apenas tabelas com linhas e mostram mensagem util quando nao ha dados.
- Categorias vazias mostram diagnostico em vez de painel branco.
- Imagens usam o componente image somente quando imageRef existe; a area fica oculta quando ausente.
- Classes continuam exibindo a secao SUBCLASSES gerada pelo importador.
- Esta distribuicao inclui dados vazios regeneraveis. Execute atualizar_dados.bat ou importar.bat para gerar data/*.lua a partir de uma fonte local autorizada.

V2.0.1 - HOTFIX COMBOBOX
------------------------
- Corrige items/values de comboBox para sintaxe de tabela Lua com chaves.
- Remove listas com colchetes que causavam LuaError no parser do Firecast.

V2.0.2 - HOTFIX REGISTRO FIRECAST
---------------------------------
- O formulario principal volta a ser uma janela acoplavel de mesa: formType="tablesDock".
- Mantem dataType br.com.minebr55.compendium5e.
- Preserva o hotfix de sintaxe dos comboBox da v2.0.1.

V2.0.3 - HOTFIX MEMORIA/PROJETO LIMPO
-------------------------------------
- Remove a copia local de sdk/ do pacote do projeto. O SDK deve vir da instalacao do Firecast SDK 3.
- Remove __pycache__ e arquivos .pyc do pacote.
- Mantem somente codigo do plugin, data, ferramentas de importacao e documentacao.
- Antes de testar: execute rdk p na pasta do projeto apenas se o SDK exigir a preparacao inicial do projeto; depois rdk c/rdk i.

V2.1.0 - NAVEGACAO CLASSE -> SUBCLASSE
--------------------------------------
- O detalhe da classe deixa de concatenar todas as subclasses no mesmo texto.
- Ao abrir uma classe, aparece um seletor Subclasse com somente subclasses cujo parentClass corresponde a classe aberta.
- "Visao geral da classe" retorna ao detalhe base da classe.
- Ao selecionar uma subclasse, o painel de detalhe troca para o registro independente da subclasse.
- Features da classe continuam no detalhe da classe; features de subclasse deixam de ser concatenadas na classe.

V2.1.1 - HOTFIX SELETOR DE SUBCLASSE
------------------------------------
- Preenche items e values do combo de subclasse em tempo de execucao.
- Comparacao parentClass/classe agora e case-insensitive.
- O seletor sempre mostra "Visao geral da classe" ao abrir uma classe.
- Quando nao ha subclasses importadas, o seletor e desativado e mostra uma mensagem explicita, em vez de parecer uma caixa quebrada.

V2.1.2 - DETALHES COMPLETOS DE SUBCLASSES
-----------------------------------------
- A subclasse selecionada recebe suas subclassFeature correspondentes.
- Associacao por parentClass + subclassKey, sem diferenca de maiusculas/minusculas.
- Features ordenadas por nivel em CARACTERISTICAS DA SUBCLASSE.
- Reimporte os dados para regenerar entries.lua com os detalhes enriquecidos.

V2.1.3 - HOTFIX IMPORTADOR DE LOOT
----------------------------------
- Corrige UnboundLocalError de import_loot.py quando loot.json nao existe na fonte.
- O importador agora inicializa um objeto vazio e gera loot_tables.lua vazio de forma segura.
- Mantem o enriquecimento de detalhes de subclasses da v2.1.2.

V2.1.4 - PACOTE CONSOLIDADO
---------------------------
- Restaura compendium.lfm e resultItem.lfm.
- Mantem navegacao Classe -> Subclasse e detalhes por subclassFeature.
- atualizar_dados.bat baixa a distribuicao publica configurada em tools/update_data.py.
- importar.bat fica disponivel como modo local/offline.
- Mantem Encounter Builder 2024, tabelas, encontros e hotfix de loot ausente.

V2.2.0 - LIMITE DE 24 MB POR ARQUIVO
------------------------------------
- index.lua e entries.lua passam a ser fachadas pequenas que carregam partes numeradas.
- O importador divide automaticamente index/entries em arquivos de ate 23 MiB alvo.
- Nenhum chunk pode atingir 24 MiB; uma entrada individual maior que isso gera erro explicito.
- tools/check_file_sizes.py verifica o projeto inteiro contra o limite de 24 MiB.

V2.2.1 - FRAGMENTACAO DO LOOT RESOLVER
--------------------------------------
- data/loot_resolver.lua agora e um agregador pequeno.
- build_loot_resolver.py divide dados em loot_resolver_001.lua, _002.lua etc.
- Cada parte usa alvo de 23 MiB e limite absoluto inferior a 24 MiB.
- Itens e grupos sao mesclados automaticamente pelo agregador em tempo de carga.
- Mantem a fragmentacao de index/entries da v2.2.0.

V2.2.2 - CARREGAMENTO SOB DEMANDA
---------------------------------
- entries.lua nao agrega mais todos os chunks em uma unica tabela na inicializacao.
- entries_manifest.lua mapeia cada ID ao chunk correto.
- compendium.lfm carrega somente o chunk necessario ao abrir um registro e o mantem em cache.
- loot_resolver permanece fragmentado em partes menores que 24 MiB.
- Mantem limite de 24 MiB e alvo de 23 MiB por chunk.


V2.2.3 - ENCONTROS ALEATORIOS
--------------------------------
- Corrige o importador para o formato atual de encounters.json: encounter[].tables[].
- Usa diceExpression de cada tabela.
- Preserva tabelas separadas por faixa de nivel/caption/prefix/suffix.
- Le diretamente min/max/result das linhas e converte max=0 para 100 nas tabelas d100.


V2.2.5 - ESTRUTURA UNICA RESTAURADA
-----------------------------------
- Volta ao layout tradicional de uma unica pasta do projeto.
- tools/, data/, .bat, .lfm e engines ficam juntos sob Compendium5e.
- Remove somente caches Python temporarios.
- Mantem as correcoes de encontros aleatorios, subclasses e carregamento sob demanda.


V2.2.6 - INSTALACAO RDK EM STAGING
----------------------------------
- Mantem tudo em uma unica pasta.
- install.bat nao executa rdk i diretamente na arvore completa.
- O script cria uma pasta temporaria somente com runtime e data/*.lua, executa rdk i e copia o RPK para output/.
- compile.bat usa o mesmo staging com rdk c.
- Evita que tools, documentacao, caches e builds antigos sejam processados pelo RDK.
IMPORTANTE: use install.bat em vez de digitar rdk i diretamente na raiz.

V2.2.7 - HOTFIX OUT OF MEMORY DO RDK
------------------------------------
- Mantem a estrutura em uma unica pasta.
- Chunks gerados de index, entries e loot_resolver agora usam alvo de 512 KiB por arquivo.
- O limite absoluto de seguranca de 24 MiB continua existindo, mas deixa de ser o tamanho normal dos chunks.
- install.bat e compile.bat limpam output antigo e compilam em staging apenas o runtime + data/*.lua.
- Mantem os encontros aleatorios corrigidos da v2.2.3, subclasses, Encounter Builder 2024 e entries sob demanda.
- Para instalar, execute install.bat em vez de chamar rdk i diretamente.
