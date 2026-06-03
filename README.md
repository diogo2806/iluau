# iLuau

O iLuau é um plugin local de MCP para Roblox Studio, feito para funcionar com o Codex.

Ele inclui:

- servidor MCP local
- painel encaixável no Roblox Studio
- árvore de seleção com filtro e expandir/colapsar
- editor de propriedades com histórico e favoritos
- edição de Attributes e Tags
- dashboard local para status da ponte e fila de jobs

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

## Arquivos principais

- `plugins/iluau/server/index.js` - ponto de entrada do servidor MCP
- `plugins/iluau/server/store.js` - estado da ponte e fila de jobs
- `plugins/iluau/dashboard/` - interface do dashboard local
- `plugins/iluau/studio-plugin/iLuau.plugin.lua` - ponte do Roblox Studio
- `plugins/iluau/skills/iluau-guide/SKILL.md` - guia de fluxo do iLuau para o Codex

## Suporte

- [GitHub Issues](https://github.com/diogo2806/iluau/issues)

## Licença

Veja [COMMERCIAL-LICENSE.md](COMMERCIAL-LICENSE.md) para a nota atual de licenciamento.
