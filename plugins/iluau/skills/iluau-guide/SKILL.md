---
name: iluau-guide
description: Use quando estiver trabalhando com o plugin iLuau, o servidor local ou a ponte do Roblox Studio exposta ao Codex.
---

# Guia do iLuau

## Visão geral

Use este plugin para controlar o Roblox Studio por meio do servidor MCP local do iLuau, do dashboard e da ponte do Studio.

## Fluxo

1. Garanta que o Roblox Studio esteja aberto e que o servidor MCP local esteja em execução.
2. **Você não precisa de seleção.** Para entender o jogo, chame `iluau.get_tree` (sem `path` lê todos os serviços padrão; com `path` aprofunda um ramo). Ele retorna a árvore com `className`, `path`, contagem de filhos e o `source` de cada Script/LocalScript/ModuleScript — sem o usuário precisar selecionar nada no Studio.
3. Para editar, aja por caminho: `iluau.set_property`, `iluau.set_properties`, `iluau.create_instance`, `iluau.delete_instance`, etc. Nenhuma dessas exige seleção.
4. Quando precisar de algo que as tools estruturadas não cobrem, use `iluau.run_luau` (`{ "source": "..." }`) para rodar Luau arbitrário no Studio com permissões de plugin; ele captura `print()` e retorna os valores. Prefira as tools estruturadas quando elas resolverem.
5. Use o dashboard para inspecionar tarefas enfileiradas, status da ponte e resultados recentes.
6. Verifique as mudanças após cada operação que altera o Studio.

## Analisar scripts e mostrar erros no Studio

O Studio não deixa o plugin LER o painel "Análise do script", mas deixa o iLuau ESCREVER diagnósticos nele. Fluxo para revisar/corrigir código:

1. Leia o código exatamente como o dev está editando (inclui rascunhos não salvos) com `iluau.get_editor_source` (`{ "path": "..." }`). Para varrer vários scripts de uma vez, use `iluau.get_tree` (já traz o `source`).
2. Encontre os problemas (sintaxe, API depreciada, globais indefinidos, tipos, etc.).
3. Injete os diagnósticos no painel nativo com `iluau.set_diagnostics` (`{ "path": "...", "diagnostics": [ { "line": 0, "character": 0, "message": "...", "severity": 1 } ] }`). `line`/`character` são 0-based; `severity`: 1=Erro, 2=Aviso, 3=Info, 4=Dica. Cada chamada substitui os diagnósticos anteriores daquele script. Use `iluau.clear_diagnostics` para limpar.
4. Para corrigir, edite por caminho (`iluau.set_property` no `Source`, ou `iluau.run_luau`).

O card "Análise do script" do painel tem o botão "Analisar seleção no Codex (ao vivo)", que envia ao chat um pedido para você fazer exatamente esse fluxo nos scripts selecionados.

## Chat dentro do Studio

O painel do Studio tem um card "Codex chat". O usuário digita ali sem sair do Studio e você responde de volta no mesmo painel:

1. Faça polling de `iluau.chat_inbox` para receber as mensagens que o usuário digitou no Studio. Cada mensagem é entregue uma única vez (depois fica marcada como `delivered`).
2. Trate o prompt como uma instrução. Se precisar de contexto do jogo, chame `iluau.get_tree` antes (não dependa de seleção). Depois use as outras tools do iLuau (`iluau.create_instance`, `iluau.set_property`, `iluau.run_luau`, etc.) para executar o que foi pedido no Studio.
3. Responda com `iluau.chat_reply` (`{ "text": "..." }`) para que o resultado apareça no card de chat do Studio.

Quando o usuário pedir para "ficar de olho no chat do Studio", entre em um loop chamando `iluau.chat_inbox` periodicamente, agindo em cada novo prompt e respondendo com `iluau.chat_reply`.

## Observações

- `iLuau` é o nome ativo do plugin e do servidor.
- O backend MCP fica em `plugins/iluau/server/index.js`.
- A ponte do Studio fica em `plugins/iluau/studio-plugin/iLuau.plugin.lua`.
