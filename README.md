# iLuau

iLuau is a local Roblox MCP plugin and Studio bridge for Codex.

It gives you:

- a local MCP server
- a dockable Roblox Studio panel
- a selection tree with filtering and expand/collapse controls
- a property editor with history and favorites
- Attributes and Tags editing
- a local dashboard for bridge state and queued jobs

## What is in this repository

- `plugins/iluau/` - the active iLuau plugin, MCP server, dashboard, and Studio bridge
- `plugins/weppy-roblox-mcp/` - archived reference material kept for compatibility and history

## Quick start

1. Install Node.js 18 or newer.
2. Open a terminal in `plugins/iluau/`.
3. Install dependencies if needed:

```bash
npm install
```

4. Start the local MCP server:

```bash
npm start
```

5. Load the MCP config from `plugins/iluau/.mcp.json` in your Codex setup or point your client at `node ./server/index.js`.
6. Copy `plugins/iluau/studio-plugin/iLuau.plugin.lua` into your Roblox Studio plugin folder.
7. Restart Roblox Studio and open the iLuau toolbar button.

The dashboard runs locally at `http://127.0.0.1:3099/`.

## Main workflows

- Inspect the current selection tree.
- Read and write properties with type assistance.
- Save and recall common property favorites.
- Edit Attributes and Tags.
- Create and delete instances.
- Queue Studio actions from Codex through the MCP bridge.

## Project files

- `plugins/iluau/server/index.js` - MCP server entry point
- `plugins/iluau/server/store.js` - bridge state and job queue
- `plugins/iluau/dashboard/` - local dashboard UI
- `plugins/iluau/studio-plugin/iLuau.plugin.lua` - Roblox Studio bridge
- `plugins/iluau/skills/iluau-guide/SKILL.md` - Codex workflow guide for iLuau

## Support

Open an issue in the repository if you find a bug or need setup help:

- [GitHub Issues](https://github.com/diogo2806/iluau/issues)

## License

See [COMMERCIAL-LICENSE.md](COMMERCIAL-LICENSE.md) for the current licensing note.
