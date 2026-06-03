---
name: iluau-guide
description: Use when working with the iLuau Roblox MCP plugin, its setup, or the Roblox Studio workflow it exposes through Codex.
---

# iLuau Guide

## Overview

Use this plugin to control Roblox Studio through the local iLuau MCP server, dashboard, and Studio bridge.

## Workflow

1. Ensure Roblox Studio is running and the MCP server is configured.
2. Prefer the narrowest action that matches the task.
3. Use the dashboard to inspect queued jobs and bridge status.
4. Verify changes after each mutating operation.

## Notes

- `iLuau` is the local plugin and server name.
- The MCP backend lives in `plugins/iluau/server/index.js`.
