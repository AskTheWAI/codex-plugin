# Ask The W Codex Plugin

Ask The W for Codex packages the `@askthew/mcp-plugin` MCP server, a Codex skill, and a trusted SessionStart reminder into a Codex-native plugin.

The npm package remains the source of truth for the MCP server binary. This repo is the Codex-native distribution wrapper.
The root `marketplace.json` lets Codex discover this checkout as a repo-backed marketplace, with the plugin package at `plugins/askthew/`.

## Brand Assets

The full public brand kit from <https://askthew.com/brand> is mirrored under `assets/brand/`.
The plugin manifest uses `assets/brand/social/product-preview.png` as its marketplace screenshot.

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
| `0.1.1` | `@askthew/mcp-plugin@0.4.29` |

Note: this checkout uses `mcpServers` inside `.mcp.json` because the current Codex plugin validator accepts that shape. If a later Codex release accepts wrapped `mcp_servers`, keep the validator-passing shape for the marketplace release branch.

## Workspace Authentication

This Codex plugin connects Codex to an Ask The W workspace. Protected tools require a workspace-bound local identity.

The marketplace entry uses `policy.authentication: "ON_USE"` because the current plugin does not have an install-time auth bridge. If the target Codex version rejects that value, block release rather than shipping with `ON_INSTALL`.

On first protected tool use:

1. If there is no local identity, the MCP server returns `needs_signup`. Complete signup with `askthew_start_signup` and `askthew_complete_signup`; the device token is stored at `~/.askthew/cloud-token.json`.
2. Until the device token is connected to a workspace, protected tools ask for workspace connection.
3. Call `askthew_start_workspace_bind`, open the returned URL, confirm the code in Ask The W, and poll `askthew_check_workspace_bind` until it reports `completed`.
4. After binding, Codex can capture session signals, create and list decisions, list signal history, request recaps, and request coaching.

The legacy terminal flow remains available for users who prefer a shell:

```bash
npx -y --package @askthew/mcp-plugin askthew-mcp install --host codex
askthew-mcp bind
```

## Hooks

The plugin manifest points at root `hooks.json` so Codex can load the session-start hook with the plugin.

Plugin hooks are non-managed. They do not run until the user reviews and trusts them with `/hooks`; trust is tied to the hook content hash. Without trust, the skill still carries the Ask The W signal guidance.

The hook injects developer context that tells Codex to capture `setup_complete` at session start, checkpoints after state changes, and `final_summary` before the final reply.

## Proactive Behavior

The plugin uses two layers to behave proactively inside Codex:

1. `hooks.json` runs on `SessionStart` for startup, resume, clear, and compact events. It injects guidance that asks Codex to call `capture_session_signal`, `create_decision`, `list_signals`, `list_decisions`, `recap`, and `coach` at the right moments.
2. `skills/ask-the-w-signals/agents/openai.yaml` sets `allow_implicit_invocation: true`, so the signal cadence can be applied without the user explicitly naming the skill every time.

That matches the MCP installer's practical behavior: the agent receives durable instructions and then calls the MCP tools during the session. A hook cannot directly call MCP tools because hooks are shell commands, not model tool calls.

For true automatic emission before the model acts, add a neutral CLI command to `@askthew/mcp-plugin` and then call it from `hooks/session-start.sh`.

The CLI command should live in the MCP package, not this plugin, so it can reuse the same auth, scope resolution, redaction, idempotency, and local outbox behavior as the MCP tool:

```bash
askthew-mcp capture-session-signal \
  --client codex \
  --kind setup_complete \
  --session-id "$CODEX_SESSION_ID" \
  --sequence 0 \
  --summary "Codex session started." \
  --metadata-json '{"source":"codex-plugin-hook","hookEventName":"SessionStart"}' \
  --json
```

This repo's `hooks/session-start.sh` is already wired for that command behind `ASKTHEW_ENABLE_HOOK_CAPTURE=1`. Once the command is published, bump the package pin, change the hook default from `0` to `1`, and keep the failure-tolerant behavior so `needs_signup` / workspace-connection responses do not fail session startup. The hook still prints `hookSpecificOutput.additionalContext` so Codex continues capturing checkpoints and final summaries during the session.

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
6. Verify the install modal metadata, tool surface, skill, hook trust flow, workspace bind, signal capture behavior, and two-workspace runtime scope behavior.
