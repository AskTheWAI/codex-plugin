---
name: ask-the-w-signals
description: Capture Ask The W session signals, decisions, recaps, and coaching checkpoints during Codex coding work.
---

# Ask The W Signals

Use Ask The W when a Codex session should leave compact observability about what changed, what was decided, what was verified, and what remains risky.

## Required Signal Cadence

Call `capture_session_signal` at these points:

1. Session start: send `kind: "setup_complete"` before other work when possible.
2. After state changes: after writes, edits, tests, builds, migrations, deploys, accepted or rejected directions, or meaningful implementation progress. Use `kind: "session_checkpoint"`, `"direction_change"`, `"implementation_update"`, or `"verification_result"`.
3. Before final reply: send `kind: "final_summary"` with what changed, what was verified, and remaining risk.

Aim for 5-15 signals per session. Keep each payload short: summary, files touched, commands run, and useful metadata.

## Scope

Do not hardcode a default `scopeKey`. Let the MCP server resolve the default workspace scope from the active Codex working directory. Pass `scopeKey` only when deliberately overriding the default scope.

## Recovery And Safety

If the first signal was missed, send `setup_complete` as soon as you notice with `metadata.recovered_missed_startup=true`.

Signals are read-only observability and are okay in planning mode. Safe to over-emit; the server dedupes when `idempotencyKey` is provided. Redact obvious secrets and never send transcripts.

## Related Tools

Use these Ask The W tools when relevant:

- `capture_session_signal` for setup, checkpoints, verification, and final summaries.
- `recap` to understand what happened before.
- `coach` for a next-step nudge.
- `create_decision` for durable architectural or product decisions.
- `list_signals` and `list_decisions` for scoped history.
