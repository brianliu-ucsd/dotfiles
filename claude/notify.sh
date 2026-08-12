#!/usr/bin/env bash

# Read JSON input passed from Claude Code via stdin
INPUT=$(cat)

# Extract session_id (uses jq if available, falls back to python3)
if command -v jq &>/dev/null; then
  SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' | cut -c 1-8)
else
  SESSION_ID=$(echo "$INPUT" | python3 -c "import sys, json; print(json.load(sys.stdin).get('session_id', 'unknown')[:8])" 2>/dev/null)
fi

# Get the current directory or git repository name to differentiate sessions
if git rev-parse --is-inside-work-tree &>/dev/null; then
  PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
  BRANCH_NAME=$(git branch --show-current 2>/dev/null)
  LOCATION="${PROJECT_NAME} (${BRANCH_NAME})"
else
  LOCATION=$(basename "$PWD")
fi

TITLE="Claude Code Finished"
MESSAGE="Session [${SESSION_ID}] in ${LOCATION} completed the task."

# Trigger native macOS desktop notification with sound
osascript -e "display notification \"${MESSAGE}\" with title \"${TITLE}\" sound name \"Glass\""

# Run: chmod +x ~/.claude/notify.sh to make script executable
