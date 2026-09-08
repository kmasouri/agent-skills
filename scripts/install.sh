#!/bin/sh
set -eu

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
skills_dir="$repo_root/skills"

targets=""
skills=""
force=0
copy_mode=0

usage() {
  cat <<'EOF'
Usage: scripts/install.sh [options] [skill...]

Options:
  --target codex|claude   Install target. Repeat to install to both. Defaults to both.
  --path PATH             Custom skill directory. Can be repeated.
  --force                 Replace existing installed skills.
  --copy                  Copy skills instead of symlinking.
  -h, --help              Show this help.

Examples:
  scripts/install.sh
  scripts/install.sh new-project
  scripts/install.sh --target codex --force
  scripts/install.sh --path "$HOME/.agents/skills" --copy --force
EOF
}

add_target() {
  case "$1" in
    codex)
      base="${CODEX_HOME:-$HOME/.codex}"
      target="$base/skills"
      ;;
    claude)
      base="${CLAUDE_HOME:-$HOME/.claude}"
      target="$base/skills"
      ;;
    *)
      target=$1
      ;;
  esac
  targets="${targets}${targets:+
}$target"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      [ "$#" -gt 1 ] || { echo "Missing value for --target" >&2; exit 1; }
      case "$2" in
        codex|claude) add_target "$2" ;;
        *) echo "Unknown target: $2" >&2; exit 1 ;;
      esac
      shift 2
      ;;
    --path)
      [ "$#" -gt 1 ] || { echo "Missing value for --path" >&2; exit 1; }
      add_target "$2"
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    --copy)
      copy_mode=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      skills="${skills}${skills:+
}$1"
      shift
      ;;
  esac
done

while [ "$#" -gt 0 ]; do
  skills="${skills}${skills:+
}$1"
  shift
done

[ -d "$skills_dir" ] || { echo "No skills directory found: $skills_dir" >&2; exit 1; }

if [ -z "$targets" ]; then
  add_target codex
  add_target claude
fi

if [ -z "$skills" ]; then
  for skill_path in "$skills_dir"/*; do
    [ -f "$skill_path/SKILL.md" ] || continue
    skills="${skills}${skills:+
}$(basename "$skill_path")"
  done
fi

[ -n "$skills" ] || { echo "No skills found in $skills_dir" >&2; exit 1; }

printf '%s\n' "$skills" | while IFS= read -r skill_name; do
  skill_path="$skills_dir/$skill_name"
  if [ ! -f "$skill_path/SKILL.md" ]; then
    echo "Unknown skill: $skill_name" >&2
    exit 1
  fi

  printf '%s\n' "$targets" | while IFS= read -r target_dir; do
    install_path="$target_dir/$skill_name"
    mkdir -p "$target_dir"

    if [ -e "$install_path" ] || [ -L "$install_path" ]; then
      if [ "$force" -ne 1 ]; then
        echo "skip $install_path already exists; use --force to replace it"
        continue
      fi
      rm -rf "$install_path"
    fi

    if [ "$copy_mode" -eq 1 ]; then
      mkdir -p "$install_path"
      cp -R "$skill_path/." "$install_path/"
      echo "copied $skill_path -> $install_path"
    else
      ln -s "$skill_path" "$install_path"
      echo "linked $install_path -> $skill_path"
    fi
  done
done
