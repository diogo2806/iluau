# Registro de mudanças

Todas as mudanças relevantes do iLuau serão registradas aqui.

## [Não publicado]

### Adicionado

- Card "Codex chat" no painel do Studio para escrever pedidos sem trocar de tela
- Endpoints HTTP `POST /api/chat/send` e `GET /api/chat/messages` para a ponte de chat
- Tools MCP `iluau.chat_inbox` e `iluau.chat_reply` para o Codex receber e responder mensagens do Studio

### Corrigido

- Forward references quebradas no plugin do Studio (`refreshSelectionTree`, `trim`, `refreshPropertyEditorState`, `syncPropertyAssist`, `queuePanelJob`) que causavam "attempt to call a nil value" e abortavam o script antes de iniciar o loop de heartbeat, deixando a ponte sempre offline e os jobs presos em "queued"

### Removido

- Plugin legado `plugins/weppy-roblox-mcp/` e todas as referências a weppy no repositório
- Instaladores e CI específicos do weppy (`install.sh`, `install.ps1`, `.github/workflows/install-test.yml`, `.github/scripts/mcp-smoke.mjs`)
- Entradas do weppy nos `marketplace.json`; `Dockerfile`, `smithery.yaml`, `llms.txt` e `llms-full.txt` agora apontam para o fluxo local do iLuau

## [0.4.0] - 2026-06-03

### Adicionado

- Filtro na árvore de seleção com busca em tempo real
- Controles de expandir e colapsar tudo na árvore do Studio
- Favoritos de propriedades com persistência local
- Linha da árvore com destaque mais legível para a seleção atual

### Melhorado

- Editor de propriedades com melhor ajuda de tipo
- Feedback mais forte de sucesso e erro para edições de propriedades e atualizações em lote
- Histórico local de propriedades persistido entre sessões do Studio

### Atualizado

- Documentação ativa, suporte, privacidade e contribuição agora refletem o projeto iLuau
- A ponte do Studio e a documentação para o Codex agora apontam para o fluxo local em `plugins/iluau`
