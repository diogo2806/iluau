# iLuau Studio Plugin

This folder contains the Roblox Studio-side bridge source for iLuau.

What it does:
- polls the local iLuau dashboard server
- reports Studio heartbeat state
- receives queued jobs from Codex
- executes a small safe action set inside Studio
- opens a dockable iLuau panel with status, a selection tree, and an attribute/tag editor

Install:
1. Copy `iLuau.plugin.lua` into a Roblox Studio plugin script.
2. Enable `HttpService` for localhost requests if required by your Studio environment.
3. Start the `iLuau` MCP server from Codex.
4. Use the `iLuau` toolbar button to open the Studio panel.

Supported job types:
- `ping`
- `inspect_selection`
- `get_properties`
- `get_attributes`
- `set_attributes`
- `get_tags`
- `set_tags`
- `set_property`
- `set_properties`
- `create_instance` with nested `children`
- `delete_instance`
- `sync_snapshot`

`set_properties` also accepts `attributes` and `tags`, so batch edits can update normal properties and metadata in one job.
