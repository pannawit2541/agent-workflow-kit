#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORKTREE_DIR="$ROOT_DIR/worktree"
CONFIG_FILE="$WORKTREE_DIR/config.yaml"

# Resolve the main worktree directory name from worktree/config.yaml (`main:` key).
# Falls back to "main" if the key is absent.
MAIN_NAME="main"
if [ -f "$CONFIG_FILE" ]; then
  parsed="$(grep -E '^main:' "$CONFIG_FILE" | head -n1 | sed -E 's/^main:[[:space:]]*//; s/[[:space:]]*$//' || true)"
  [ -n "$parsed" ] && MAIN_NAME="$parsed"
fi
MAIN_WORKTREE="$WORKTREE_DIR/$MAIN_NAME"

if [ ! -d "$MAIN_WORKTREE/.git" ]; then
  cat >&2 <<EOF
Error: Main worktree not found at $MAIN_WORKTREE

Set up the kit first:
  1. Set 'main:' in $CONFIG_FILE to your worktree directory name (currently: $MAIN_NAME)
  2. Clone your project into it:  git clone <repo-url> worktree/$MAIN_NAME
EOF
  exit 1
fi

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  add <branch> [name]        Create a worktree for an existing <branch> (name defaults to branch basename)
  add --new <branch> [name] [base]
                             Create a new branch and worktree from [base] (default: origin/main)
  list                  List all worktrees
  prune                 Remove stale worktree registrations
  remove <name>         Remove a worktree by directory name
  fetch                 Fetch latest from origin in main worktree
  pull                  Pull and rebase from origin in main worktree

Examples:
  $(basename "$0") add feature/new-ui
  $(basename "$0") add --new feature/new-ui new-ui
  $(basename "$0") add --new feature/new-ui new-ui origin/main
  $(basename "$0") add fix/bug-123 hotfix-123
  $(basename "$0") list
  $(basename "$0") remove new-ui
  $(basename "$0") prune
EOF
}

cmd_add() {
  local create_new=0

  if [ "${1:-}" = "--new" ] || [ "${1:-}" = "-b" ]; then
    create_new=1
    shift
  fi

  local branch="$1"
  shift

  local name="$(basename "$branch")"
  local base="origin/main"

  if [ "$create_new" -eq 1 ]; then
    case "$#" in
      0)
        ;;
      1)
        if git -C "$MAIN_WORKTREE" rev-parse --verify --quiet "$1^{commit}" >/dev/null; then
          base="$1"
        else
          name="$1"
        fi
        ;;
      *)
        name="$1"
        base="$2"
        ;;
    esac
  else
    name="${1:-$(basename "$branch")}"
  fi

  local target="$WORKTREE_DIR/$name"

  if [ -d "$target" ]; then
    echo "Error: Directory already exists: $target"
    exit 1
  fi

  if [ "$create_new" -eq 1 ]; then
    if git -C "$MAIN_WORKTREE" show-ref --verify --quiet "refs/heads/$branch"; then
      echo "Error: Local branch already exists: $branch"
      exit 1
    fi

    echo "Creating worktree '$name' with new branch '$branch' from '$base'..."
    git -C "$MAIN_WORKTREE" worktree add -b "$branch" "$target" "$base"
  else
    echo "Creating worktree '$name' for branch '$branch'..."
    git -C "$MAIN_WORKTREE" worktree add "$target" "$branch"
  fi

  echo "Copying .env files from main worktree..."
  find "$MAIN_WORKTREE" -name '.env' \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/.next/*' \
    -not -path '*/dist/*' | while read -r envfile; do
    relpath="${envfile#$MAIN_WORKTREE/}"
    mkdir -p "$(dirname "$target/$relpath")"
    cp "$envfile" "$target/$relpath"
    echo "  Copied $relpath"
  done

  echo "Done: $target"
}

cmd_list() {
  echo "Worktrees:"
  git -C "$MAIN_WORKTREE" worktree list | while read -r path hash branch; do
    local name
    name="$(basename "$path")"
    if [ "$path" = "$MAIN_WORKTREE" ]; then
      echo "  [main] $name  $branch"
    else
      echo "  [$name]  $branch"
    fi
  done
}

cmd_prune() {
  echo "Pruning stale worktree registrations..."
  git -C "$MAIN_WORKTREE" worktree prune
  echo "Done."
}

cmd_remove() {
  local name="$1"
  local target="$WORKTREE_DIR/$name"

  if [ ! -d "$target" ]; then
    echo "Error: Worktree not found: $target"
    exit 1
  fi

  if [ "$target" = "$MAIN_WORKTREE" ]; then
    echo "Error: Cannot remove the main worktree"
    exit 1
  fi

  echo "Removing worktree: $name..."
  git -C "$MAIN_WORKTREE" worktree remove "$target"
  echo "Done."
}

cmd_fetch() {
  echo "Fetching from origin..."
  git -C "$MAIN_WORKTREE" fetch origin
  echo "Done."
}

cmd_pull() {
  echo "Pulling and rebasing from origin..."
  git -C "$MAIN_WORKTREE" pull -r origin
  echo "Done."
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

command="$1"
shift

case "$command" in
  add)
    [ $# -lt 1 ] && { echo "Error: branch required"; usage; exit 1; }
    cmd_add "$@"
    ;;
  list)
    cmd_list
    ;;
  prune)
    cmd_prune
    ;;
  remove)
    [ $# -lt 1 ] && { echo "Error: name required"; usage; exit 1; }
    cmd_remove "$@"
    ;;
  fetch)
    cmd_fetch
    ;;
  pull)
    cmd_pull
    ;;
  *)
    echo "Error: Unknown command: $command"
    usage
    exit 1
    ;;
esac
