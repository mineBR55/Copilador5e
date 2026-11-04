# Arquitetura proposta do gerador de loot

## Objetivo
Separar dados, motor de rolagem e UI para nao acoplar regras 2014/2024 ao LuaForm.

## Entrada local
- data/loot.json do conjunto local autorizado.
- itens importados no indice atual para resolver referencias de itens magicos.

## Build/importacao
O importador Python deve converter loot.json para `data/loot_tables.lua`, preservando:
- source/edicao
- faixas de CR
- tipo de tabela/modo
- intervalos de d100
- moedas
- referencias de gemas/objetos/itens magicos

## Runtime Lua
`loot_engine.lua` deve ser puro e sem UI:
- rollDie/rollDice
- selectByRange
- generateIndividual(cr, edition)
- generateHoard(cr, edition)
- retorno estruturado em vez de texto pronto

## UI
Painel Ferramentas > Loot:
- Edicao
- Modo
- CR/faixa
- Hoard quando aplicavel
- Gerar / Limpar
- resultado em secoes Moedas, Objetos/Gemas, Itens Magicos

## Seguranca/desempenho
- carregar `loot_tables.lua` apenas ao abrir a ferramenta
- nao gravar resultados em NodeDatabase
- limitar historico a estado local da instancia
- nao duplicar tabelas de regras manualmente no codigo
