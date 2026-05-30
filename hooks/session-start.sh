#!/usr/bin/env bash
set -euo pipefail

session_id="${CODEX_SESSION_ID:-codex-$(date -u +%Y%m%dT%H%M%SZ)-${RANDOM:-0}}"
auto_capture_status="skipped"

# Enable after @askthew/mcp-plugin publishes `askthew-mcp capture-session-signal`.
# Keeping this opt-in avoids a slow or noisy SessionStart hook while the pinned
# package version does not yet contain that CLI command.
if [[ "${ASKTHEW_ENABLE_HOOK_CAPTURE:-0}" == "1" ]]; then
  package="${ASKTHEW_MCP_PACKAGE:-@askthew/mcp-plugin@0.4.27}"
  idempotency_key="$(uuidgen 2>/dev/null || printf 'hook-%s-%s' "$session_id" "$(date +%s)")"
  set +e
  capture_output="$(
    npx -y --package "$package" askthew-mcp capture-session-signal \
      --client codex \
      --kind setup_complete \
      --session-id "$session_id" \
      --sequence 0 \
      --summary "Codex session started." \
      --idempotency-key "$idempotency_key" \
      --metadata-json '{"source":"codex-plugin-hook","hookEventName":"SessionStart"}' \
      --json 2>&1
  )"
  capture_exit=$?
  set -e
  if [[ "$capture_exit" -eq 0 ]] && printf '%s' "$capture_output" | grep -q '"ok"[[:space:]]*:[[:space:]]*true'; then
    auto_capture_status="captured_or_queued"
  else
    auto_capture_status="not_captured"
  fi
fi

cat <<JSON
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Ask The W is available. Use sessionId ${session_id}. Hook setup_complete capture status: ${auto_capture_status}. If status is captured_or_queued, continue with capture_session_signal sequence 1 after state changes and final_summary before the final reply. If status is skipped or not_captured, call capture_session_signal with kind setup_complete and sequence 0 as soon as the MCP tool is available. Use create_decision for durable decisions, list_signals and list_decisions for scoped history, recap for prior context, and coach for next-step guidance. If a protected tool asks for workspace connection, complete signup if needed, then start and check workspace bind. Keep payloads compact and do not include transcripts or secrets."
  }
}
JSON
