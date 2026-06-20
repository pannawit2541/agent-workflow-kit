#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPENSPEC_DIR="$ROOT_DIR/openspec"

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  status    Show changes, specs, and archive counts
  list      Show active changes with progress
  clean     Remove all changes, specs, and archive
  reset     Delete openspec/ entirely and re-init

Examples:
  $(basename "$0") status
  $(basename "$0") clean
  $(basename "$0") reset
EOF
}

count_items() {
  local dir="$1"
  if [ -d "$dir" ]; then
    ls -1 "$dir" 2>/dev/null | grep -v '^$' | wc -l | tr -d ' '
  else
    echo "0"
  fi
}

count_active_changes() {
  local dir="$OPENSPEC_DIR/changes"
  if [ -d "$dir" ]; then
    find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name archive | wc -l | tr -d ' '
  else
    echo "0"
  fi
}

cmd_status() {
  echo "=== OpenSpec Status ==="
  echo "  Changes: $(count_active_changes)"
  echo "  Specs:   $(count_items "$OPENSPEC_DIR/specs")"
  echo "  Archive: $(count_items "$OPENSPEC_DIR/changes/archive")"
  echo ""
  if command -v openspec &>/dev/null; then
    openspec list 2>/dev/null || echo "  (no active changes)"
  else
    echo "  openspec CLI not found. Run: npm install -g @fission-ai/openspec@latest"
  fi
}

cmd_list() {
  echo "=== Active OpenSpec Changes ==="
  if command -v openspec &>/dev/null; then
    openspec list 2>/dev/null || echo "  (no active changes)"
  else
    echo "  openspec CLI not found."
    for dir in "$OPENSPEC_DIR/changes"/*/; do
      [ -d "$dir" ] || continue
      echo "  - $(basename "$dir")"
    done | grep -v '  - archive$'
  fi
}

cmd_clean() {
  echo "Cleaning OpenSpec..."
  find "$OPENSPEC_DIR/changes" -mindepth 1 -maxdepth 1 ! -name archive -exec rm -rf {} + 2>/dev/null || true
  rm -rf "$OPENSPEC_DIR/changes/archive/"*
  rm -rf "$OPENSPEC_DIR/specs/"*
  echo "Done. openspec/ is now empty."
}

cmd_reset() {
  echo "Resetting OpenSpec..."
  rm -rf "$OPENSPEC_DIR"

  if ! command -v openspec &>/dev/null; then
    echo "Error: openspec CLI not found. Run: npm install -g @fission-ai/openspec@latest"
    exit 1
  fi

  echo "Re-initializing..."
  openspec init --tools claude,codex
  echo "Done. OpenSpec reset to empty state."
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

command="$1"
shift

case "$command" in
  status) cmd_status ;;
  list)   cmd_list   ;;
  clean)  cmd_clean  ;;
  reset)  cmd_reset  ;;
  *)
    echo "Error: Unknown command: $command"
    usage
    exit 1
    ;;
esac
