---
name: iluau-guide
description: Use when working with the iLuau Roblox MCP plugin, its local server, or the Roblox Studio bridge it exposes through Codex.
---

# iLuau Guide

## Overview

Use this plugin to control Roblox Studio through the local iLuau MCP server, dashboard, and Studio bridge.

## Workflow

1. Ensure Roblox Studio is running and the local MCP server is started.
2. Prefer the narrowest action that matches the task.
3. Use the dashboard to inspect queued jobs, bridge status, and recent results.
4. Verify changes after each mutating operation.

## Notes

- `iLuau` is the active plugin and server name.
- The MCP backend lives in `plugins/iluau/server/index.js`.
- The Studio bridge lives in `plugins/iluau/studio-plugin/iLuau.plugin.lua`.
