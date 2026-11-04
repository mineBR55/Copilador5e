# Plano tecnico: resolucao completa de tabelas magicas

## Estado implementado
1. `import_loot.py` separa `individual`, `hoard` e as tabelas magicas do `loot.json`.
2. `table_engine.lua` centraliza rolagem de dados, selecao por intervalo e limpeza de tags.
3. `loot_engine.lua` resolve a rolagem principal, quantidade e cada d100 de tabela A-I.

## Fase 1 - normalizacao da entrada
- Preservar source, tipo da tabela, min/max e resultado bruto.
- Guardar a referencia completa `nome|source`, nao apenas o nome visivel.
- Aceitar resultados simples, listas e objetos estruturados.

## Fase 2 - resolucao de entidades
- Construir mapa por `name|source` para itens e grupos.
- Resolver tags `{@item ...}` sem perder a fonte.
- Se o resultado for itemGroup, escolher uma entrada valida do grupo.
- Se for generic variant, combinar `magicvariants.json` com `items-base.json`.

## Fase 3 - variantes magicas
- Carregar baseitem, item, itemGroup e magicvariant.
- Aplicar regras de inclusao/exclusao da variante ao item-base.
- Herdar nome, raridade, propriedades, requisito de sintonizacao e valor-base.
- Gerar uma identificacao estavel para a variante concreta.

## Fase 4 - saida rica
Cada item de loot deve retornar:
- nome concreto;
- source;
- tabela e d100 usados;
- raridade;
- sintonizacao;
- valor 2024;
- link interno/id do compendio, quando existir.

## Fase 5 - validacao
- Verificar cobertura de todos os intervalos 1-100 por tabela.
- Detectar referencias sem entidade correspondente.
- Testar sementes fixas com resultados esperados.
- Gerar relatorio de tabelas, referencias e variantes nao resolvidas.
