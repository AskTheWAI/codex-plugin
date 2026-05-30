---
name: ask-the-w-signals
description: Capture Ask The W session signals, decision logs, scoped history, recaps, and coaching during Codex coding work.
---

# Ask The W Signals

Use Ask The W when a Codex workspace session should leave durable observability about what changed, what was decided, what was verified, and what prior scoped history or coaching should inform the next step.

If a protected tool asks for workspace connection, complete the workspace connection first: call `askthew_start_signup` and `askthew_complete_signup` if there is no local identity, then call `askthew_start_workspace_bind`, ask the user to open the returned URL and confirm the code, and poll `askthew_check_workspace_bind` until it reports `completed`.

## Required Signal Cadence

Call `capture_session_signal` at these points:

1. Session start: send `kind: "setup_complete"` before other work when possible.
2. After state changes: after writes, edits, tests, builds, migrations, deploys, accepted or rejected directions, or meaningful implementation progress. Use `kind: "session_checkpoint"`, `"direction_change"`, `"implementation_update"`, or `"verification_result"`.
3. Before final reply: send `kind: "final_summary"` with what changed, what was verified, and remaining risk.

Use 5-15 meaningful signals as a quality baseline, not a cap. Capture every useful checkpoint without artificial limits. Keep each payload short: summary, files touched, commands run, and useful metadata.

Use `coach` when the session needs next-step guidance, especially after a major checkpoint, a recovered startup, or before the final reply.

## Scope

Do not hardcode a default `scopeKey`. Let the MCP server resolve the default workspace scope from the active Codex working directory. Pass `scopeKey` only when deliberately overriding the default scope.

## Recovery And Safety

If the first signal was missed, send `setup_complete` as soon as you notice with `metadata.recovered_missed_startup=true`.

Signals are read-only observability and are okay in planning mode. Safe to over-emit; the server dedupes when `idempotencyKey` is provided. Redact obvious secrets and never send transcripts.

## Related Tools

Use these Ask The W tools when relevant:

- `capture_session_signal` for setup, checkpoints, verification, and final summaries.
- `recap` to understand what happened before.
- `coach` for next-step guidance.
- `create_decision` for durable architectural or product decisions.
- `list_signals` and `list_decisions` for scoped history.
- `askthew_start_workspace_bind` and `askthew_check_workspace_bind` when workspace connection is required.
