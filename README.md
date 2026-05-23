# Ask The W Codex Plugin

Ask The W for Codex packages the `@askthew/mcp-plugin` MCP server, a Codex skill, and a trusted SessionStart reminder into a Codex-native plugin.

The npm package remains the source of truth for the MCP server binary. This repo is the Codex distribution wrapper.

## Install From This Marketplace

Add the repo-backed marketplace:

```bash
codex plugin marketplace add AskTheWAI/codex-plugin --ref main
```

Then install **Ask The W** from the Codex Plugins UI or from `/plugins` in the Codex REPL. `codex-cli 0.130.0` does not provide `codex plugin install <name>`.

For a local smoke test from this repo checkout:

```bash
codex plugin marketplace add .
```

## Version Mapping

- `.codex-plugin/plugin.json` version tracks this Codex wrapper.
- `.mcp.json` pins a concrete `@askthew/mcp-plugin` version.
- Bump the plugin version whenever the pinned MCP package changes so `codex plugin marketplace upgrade` is the team update signal.

Current mapping:

| Codex plugin | MCP package |
| --- | --- |
| `0.1.0` | `@askthew/mcp-plugin@0.4.27` |

Note: this checkout uses `mcpServers` inside `.mcp.json` because the current Codex plugin validator accepts that shape. If a later Codex release accepts wrapped `mcp_servers`, keep the validator-passing shape for the marketplace release branch.

## Authentication

This plugin uses first-use authentication for MVP. The marketplace entry uses `policy.authentication: "ON_USE"`. If the target Codex version rejects that value, block release rather than shipping with `ON_INSTALL`.

On first protected tool use without a local token, the MCP server returns `needs_signup`. Complete signup with `askthew_start_signup` and `askthew_complete_signup`; the device token is stored at `~/.askthew/cloud-token.json`.

The legacy terminal OTP flow remains available:

```bash
npx -y --package @askthew/mcp-plugin askthew-mcp install --host codex
```

## Hooks

The plugin bundles `hooks/hooks.json`. Codex auto-discovers that default file, so `plugin.json` intentionally omits a `hooks` field.

Plugin hooks are non-managed. They do not run until the user reviews and trusts them with `/hooks`; trust is tied to the hook content hash. Without trust, the skill still carries the Ask The W signal guidance.

The hook injects developer context only. It does not emit telemetry itself.

## Workspace Sharing

After installing and verifying the plugin, share it with teammates from the Codex Plugins UI:

1. Open **Plugins**.
2. Open **Created by you**.
3. Select **Ask The W**.
4. Use **Share** to invite teammates or allow anyone in the workspace with the link.

Sharing is workspace-scoped and can be revoked with **Stop sharing**. It does not publish the plugin to the public Plugin Directory.

## Release Checklist

1. Publish the pinned `@askthew/mcp-plugin` version.
2. Confirm `.mcp.json` pins that published version.
3. Bump `.codex-plugin/plugin.json` if the pin changed.
4. Tag this repo with the plugin version.
5. Run `codex plugin marketplace upgrade` from a subscriber machine.
6. Verify the install modal metadata, tool surface, skill, hook trust flow, first-use auth, and two-workspace runtime scope behavior.
