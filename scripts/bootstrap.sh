#!/usr/bin/env bash
# Copy this template into a new or existing git project.
# Usage:
#   ./scripts/bootstrap.sh /path/to/project
#   ./scripts/bootstrap.sh /path/to/project --force
#   ./scripts/bootstrap.sh /path/to/project --personal-skills
#
# --force            overwrite files that already exist
# --personal-skills  also copy .cursor/skills into ~/.cursor/skills (machine-wide)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-}"
FORCE=0
PERSONAL=0

if [[ -z "$TARGET" || "$TARGET" == --* ]]; then
  echo "Usage: $0 <target-project-dir> [--force] [--personal-skills]" >&2
  exit 1
fi
shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1 ;;
    --personal-skills) PERSONAL=1 ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
  shift
done

TARGET="$(cd "$TARGET" && pwd)"
install_file() {
  local rel="$1"
  local src="$ROOT/$rel"
  local dest="$TARGET/$rel"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && "$FORCE" -eq 0 ]]; then
    echo "skip  $rel (exists)"
    return
  fi
  cp "$src" "$dest"
  echo "write $rel"
}

echo "Bootstrapping AI project format into $TARGET"

install_file "AGENTS.md"
install_file "CLAUDE.md"
install_file "REVIEW.md"
install_file ".gitignore"
install_file ".github/ISSUE_TEMPLATE/feature.yml"
install_file ".github/ISSUE_TEMPLATE/bug.yml"
install_file ".github/ISSUE_TEMPLATE/config.yml"
install_file ".github/pull_request_template.md"
mkdir -p "$TARGET/intent"
if [[ ! -e "$TARGET/intent/.gitkeep" ]]; then
  cp "$ROOT/intent/.gitkeep" "$TARGET/intent/.gitkeep"
  echo "write intent/.gitkeep"
fi

# Skills: copy each skill dir if missing, or --force
while IFS= read -r skill_dir; do
  name="$(basename "$skill_dir")"
  dest="$TARGET/.cursor/skills/$name"
  if [[ -d "$dest" && "$FORCE" -eq 0 ]]; then
    echo "skip  .cursor/skills/$name (exists)"
    continue
  fi
  mkdir -p "$TARGET/.cursor/skills"
  rm -rf "$dest"
  cp -R "$skill_dir" "$dest"
  echo "write .cursor/skills/$name"
done < <(find "$ROOT/.cursor/skills" -mindepth 1 -maxdepth 1 -type d | sort)

slug=""
if [[ -d "$TARGET/.git" ]] && command -v git >/dev/null; then
  origin="$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)"
  if [[ "$origin" == git@github.com:*/* ]]; then
    slug="${origin#git@github.com:}"
    slug="${slug%.git}"
  elif [[ "$origin" == https://github.com/* ]]; then
    slug="${origin#https://github.com/}"
    slug="${slug%.git}"
  fi
  if [[ -n "$slug" ]]; then
    cfg="$TARGET/.github/ISSUE_TEMPLATE/config.yml"
    if [[ -f "$cfg" ]]; then
      tmp="$(mktemp)"
      sed "s|github.com/OWNER/REPO|github.com/${slug}|g" "$cfg" > "$tmp"
      mv "$tmp" "$cfg"
      echo "write .github/ISSUE_TEMPLATE/config.yml (repo $slug)"
    fi
  fi
fi

if [[ -n "$slug" ]] && command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
  for spec in "type:feature:0E8A16" "type:bug:D73A4A" "type:chore:BFD4F2" \
              "priority:high:B60205" "priority:normal:C5DEF5"; do
    name="${spec%:*}"
    color="${spec##*:}"
    gh label create "$name" --color "$color" --repo "$slug" >/dev/null 2>&1 || true
  done
  echo "ok    GitHub labels on $slug (created or already present)"
fi

if [[ "$PERSONAL" -eq 1 ]]; then
  dest_root="${HOME}/.cursor/skills"
  mkdir -p "$dest_root"
  while IFS= read -r skill_dir; do
    name="$(basename "$skill_dir")"
    dest="$dest_root/$name"
    if [[ -d "$dest" && "$FORCE" -eq 0 ]]; then
      echo "skip  ~/.cursor/skills/$name (exists)"
      continue
    fi
    rm -rf "$dest"
    cp -R "$skill_dir" "$dest"
    echo "write ~/.cursor/skills/$name"
  done < <(find "$ROOT/.cursor/skills" -mindepth 1 -maxdepth 1 -type d | sort)
fi

echo "Done. Fill AGENTS.md Commands from this project's package.json / Makefile."
