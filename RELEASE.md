# Release And Team Sharing

This repo is the Codex-native distribution wrapper for `@askthew/mcp-plugin`.

## Prerequisites

1. Publish `@askthew/mcp-plugin@0.4.27` to npm.
2. Push this repository to `https://github.com/AskTheWAI/codex-plugin`.
3. Confirm `.mcp.json` still pins the published MCP version.
4. Confirm `.agents/plugins/marketplace.json` validates and uses `source.path: "./"`.

## Publish MCP Package

From the monorepo:

```bash
npm_config_cache=/tmp/askthew-npm-cache npm publish --workspace @askthew/mcp-plugin --access public
```

If npm returns `401 Unauthorized`, log in with an account that can publish `@askthew/mcp-plugin`, then rerun the command.

## Push Plugin Repo

From this plugin repo root:

```bash
git init
git add .
git commit -m "Initial Ask The W Codex plugin"
git branch -M main
git remote add origin https://github.com/AskTheWAI/codex-plugin.git
git push -u origin main
```

If the GitHub repo does not exist yet, create `AskTheWAI/codex-plugin` first.

## Marketplace Install

Teammates add the repo-backed marketplace once:

```bash
codex plugin marketplace add AskTheWAI/codex-plugin --ref main
```

Then they install **Ask The W** from the Codex Plugins UI or `/plugins`.

## Team Sharing

After the plugin is installed and visible in Codex:

1. Open **Plugins**.
2. Open **Created by you**.
3. Select **Ask The W**.
4. Use **Share** to invite teammates or allow anyone in the workspace with the link.
5. Verify recipients can install from **Shared with you**.
6. Verify **Stop sharing** revokes new install access.

## Verification Gates

- `python3 /Users/ym/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py askthew-codex-plugin`
- `npm test --workspace @askthew/mcp-plugin`
- `npm run docs:validate --workspace @askthew/app`
- `npm_config_cache=/tmp/askthew-npm-cache npm pack --workspace @askthew/mcp-plugin --dry-run`
