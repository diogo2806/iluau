# iLuau Studio Plugin

This folder contains the Roblox Studio bridge for iLuau.

## What it does

- polls the local iLuau dashboard server
- reports Studio heartbeat state
- receives queued jobs from Codex
- executes the safe Studio action set
- opens a dockable panel with:
  - connection status
  - selection tree
  - property editor
  - property favorites
  - Attributes and Tags editor

## Install

1. Copy `iLuau.plugin.lua` into a Roblox Studio plugin script.
2. Enable `HttpService` for localhost requests if your Studio setup requires it.
3. Start the local MCP server from `plugins/iluau/`.
4. Open the iLuau toolbar button in Studio.

## Supported job types

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

`set_properties` accepts `properties`, `attributes`, and `tags`, so batch edits can update instance state and metadata in one job.
