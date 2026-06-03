# Plugin Studio do iLuau

Esta pasta contém a ponte do Roblox Studio para o iLuau.

## O que faz

- consulta o servidor local do dashboard do iLuau
- reporta o estado do heartbeat do Studio
- recebe tarefas enfileiradas pelo Codex
- executa o conjunto seguro de ações no Studio
- abre um painel encaixável com:
  - status da conexão
  - árvore de seleção
  - editor de propriedades
  - favoritos de propriedades
  - editor de Attributes e Tags

## Instalação

1. Copie `iLuau.plugin.lua` para um script de plugin do Roblox Studio.
2. Habilite `HttpService` para requisições locais, se o seu ambiente exigir.
3. Inicie o servidor MCP local em `plugins/iluau/`.
4. Abra o botão do iLuau no Studio.

## Tipos de tarefa suportados

- `ping`
- `inspect_selection`
- `get_properties`
- `get_attributes`
- `set_attributes`
- `get_tags`
- `set_tags`
- `set_property`
- `set_properties`
- `create_instance` com `children` aninhados
- `delete_instance`
- `sync_snapshot`

`set_properties` aceita `properties`, `attributes` e `tags`, então edições em lote podem atualizar estado e metadados em uma única tarefa.
