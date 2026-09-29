#!/usr/bin/env bash
# Copy this template into a new or existing git project.
# Usage:
#   ./scripts/bootstrap.sh /path/to/project
#   ./scripts/bootstrap.sh /path/to/project --force
#   ./scripts/bootstrap.sh /path/to/project --personal-skills
#
# --force            overwrite files / skills that already exist
# --personal-skills  also install skills machine-wide in ~/.agents/skills and
#                    link them into ~/.claude/skills and ~/.cursor/skills
#
# Skills are written once to .agents/skills/ and exposed to every agent through
# symlinks: .claude/skills -> ../.agents/skills (Claude Code) and
# .cursor/skills -> ../.agents/skills (Cursor). Codex reads .agents/skills directly.
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

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
SKILLS_SRC="$ROOT/.agents/skills"

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

# copy_skills <dest-root> <label>: copy each skill dir unless present (or --force)
copy_skills() {
  local dest_root="$1" label="$2" skill_dir name dest
  mkdir -p "$dest_root"
  while IFS= read -r skill_dir; do
    name="$(basename "$skill_dir")"
    dest="$dest_root/$name"
    if [[ -e "$dest" && "$FORCE" -eq 0 ]]; then
      echo "skip  $label/$name (exists)"
      continue
    fi
    rm -rf "$dest"
    cp -R "$skill_dir" "$dest"
    echo "write $label/$name"
  done < <(find "$SKILLS_SRC" -mindepth 1 -maxdepth 1 -type d | sort)
}

# link_skills <agent-dir> <canonical-skills-dir> <label>
# If <agent-dir>/skills is absent, symlink the whole folder. If it already
# exists as a real directory (the project has its own skills there), link each
# template skill individually so nothing of theirs is touched.
link_skills() {
  local agent_dir="$1" canonical="$2" label="$3" link rel skill_dir name
  link="$agent_dir/skills"
  if [[ -L "$link" ]]; then
    echo "ok    $label/skills -> $(readlink "$link") (symlink present)"
    return
  fi
  if [[ ! -e "$link" ]]; then
    mkdir -p "$agent_dir"
    rel="$(python3 -c 'import os,sys;print(os.path.relpath(sys.argv[1],sys.argv[2]))' "$canonical" "$agent_dir")"
    ln -s "$rel" "$link"
    echo "link  $label/skills -> $rel"
    return
  fi
  while IFS= read -r skill_dir; do
    name="$(basename "$skill_dir")"
    if [[ -e "$link/$name" ]]; then
      echo "skip  $label/skills/$name (exists)"
      continue
    fi
    rel="$(python3 -c 'import os,sys;print(os.path.relpath(sys.argv[1],sys.argv[2]))' "$canonical/$name" "$link")"
    ln -s "$rel" "$link/$name"
    echo "link  $label/skills/$name -> $rel"
  done < <(find "$canonical" -mindepth 1 -maxdepth 1 -type d | sort)
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
install_file ".github/workflows/pr-policy.yml"
install_file ".github/copilot-instructions.md"
mkdir -p "$TARGET/intent"
if [[ ! -e "$TARGET/intent/.gitkeep" ]]; then
  cp "$ROOT/intent/.gitkeep" "$TARGET/intent/.gitkeep"
  echo "write intent/.gitkeep"
fi

copy_skills "$TARGET/.agents/skills" ".agents/skills"
link_skills "$TARGET/.claude" "$TARGET/.agents/skills" ".claude"
link_skills "$TARGET/.cursor" "$TARGET/.agents/skills" ".cursor"

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
  copy_skills "$HOME/.agents/skills" "~/.agents/skills"
  for agent in .claude .cursor; do
    link_skills "$HOME/$agent" "$HOME/.agents/skills" "~/$agent"
  done
fi

echo "Done. Fill AGENTS.md Commands from this project's package.json / Makefile."
echo "      Then: commit, and protect main (see .agents/skills/ci-guardrails)."
