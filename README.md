# iLuau

O iLuau é um plugin local de MCP para Roblox Studio, feito para funcionar com o Codex.

Ele inclui:

- servidor MCP local
- painel encaixável no Roblox Studio
- árvore de seleção com filtro e expandir/colapsar
- editor de propriedades com histórico e favoritos
- edição de Attributes e Tags
- chat do Codex embutido no painel (escreva sem sair do Studio)
- dashboard local para status da ponte e fila de tarefas

## O que existe neste repositório

- `plugins/iluau/` - plugin ativo do iLuau, servidor MCP, dashboard e ponte do Studio
- `plugins/weppy-roblox-mcp/` - material legado mantido apenas como referência e compatibilidade

## Início rápido

1. Instale Node.js 18 ou superior.
2. Abra um terminal em `plugins/iluau/`.
3. Instale as dependências, se necessário:

```bash
npm install
```

4. Inicie o servidor MCP local:

```bash
npm start
```

5. Aponte seu cliente Codex para `plugins/iluau/.mcp.json` ou use `node ./server/index.js`.
6. Copie `plugins/iluau/studio-plugin/iLuau.plugin.lua` para a pasta de plugins do Roblox Studio.
7. Reinicie o Roblox Studio e abra o botão do iLuau.

O dashboard local roda em `http://127.0.0.1:3099/`.

## Fluxos principais

- Inspecionar a árvore da seleção atual.
- Ler e alterar propriedades com ajuda de tipo.
- Salvar e reutilizar propriedades favoritas.
- Editar Attributes e Tags.
- Criar e remover instâncias.
- Enfileirar ações do Studio pelo MCP.
- Conversar com o Codex pelo card "Codex chat" sem sair do Studio.

## Chat com o Codex dentro do Studio

O painel do Studio tem um card **Codex chat**. Você digita um pedido ali (Enter envia) e ele vai para a fila de chat do servidor local. O Codex lê os pedidos com a tool `iluau.chat_inbox`, executa o que for preciso usando as outras tools do iLuau e responde com `iluau.chat_reply` — a resposta aparece no mesmo painel.

Para o Codex acompanhar o chat, peça a ele (uma vez, no seu cliente Codex) algo como *"fique de olho no chat do iLuau: chame `iluau.chat_inbox` periodicamente, atenda os pedidos no Studio e responda com `iluau.chat_reply`"*.

## Arquivos principais

- `plugins/iluau/server/index.js` - ponto de entrada do servidor MCP
- `plugins/iluau/server/store.js` - estado da ponte e fila de tarefas
- `plugins/iluau/dashboard/` - interface do dashboard local
- `plugins/iluau/studio-plugin/iLuau.plugin.lua` - ponte do Roblox Studio
- `plugins/iluau/skills/iluau-guide/SKILL.md` - guia de fluxo do iLuau para o Codex

## Suporte

- [GitHub Issues](https://github.com/diogo2806/iluau/issues)

## Licença

Veja [COMMERCIAL-LICENSE.md](COMMERCIAL-LICENSE.md) para a nota atual de licenciamento.
