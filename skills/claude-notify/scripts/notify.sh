#!/bin/bash
# Claude Code notification script for macOS
# Uses osascript (built-in, zero dependencies)

TYPE="${1:-Stop}"
DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
NAME="$(basename "$DIR" 2>/dev/null || echo "unknown")"
MODEL="${ANTHROPIC_MODEL:-unknown}"
BRANCH="$(git -C "$DIR" branch --show-current 2>/dev/null || echo "no-git")"

case "$TYPE" in
  Notification)
    TITLE="[$NAME] Claude Waiting"
    ;;
  PermissionDenied)
    TITLE="[$NAME] Permission Needed"
    ;;
  Stop)
    TITLE="[$NAME] Claude Done"
    ;;
  *)
    exit 0
    ;;
esac

BODY="Dir: ${DIR}
Branch: ${BRANCH}
Model: ${MODEL}"

osascript -e "display notification \"${BODY}\" with title \"${TITLE}\" sound name \"Glass\""
