#!/usr/bin/env bash
set -euo pipefail

cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Ask The W is available. Use capture_session_signal for setup_complete at session start, checkpoints after state changes, and final_summary before the final reply. Recover a missed startup with metadata.recovered_missed_startup=true. Aim for 5-15 compact signals per session. Do not include transcripts or secrets."
  }
}
JSON
