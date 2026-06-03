# Privacy

iLuau is designed to run locally on your machine.

## What stays local

- The MCP server runs on localhost.
- The Studio bridge uses local HTTP requests to the dashboard server.
- Plugin settings, property history, favorites, and tree filter state are stored locally in Roblox Studio plugin settings.

## What this repository does not document

- No telemetry pipeline is defined in the current iLuau code in this repository.
- No paid-plan analytics are used in the active iLuau plugin.
- No project files or script contents are intentionally sent to a remote service by the current iLuau docs or bridge code.

## If telemetry is added later

Any future analytics or telemetry work should be documented here before release, including what data is collected, why it is collected, and how to opt out.
