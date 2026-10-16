#!/usr/bin/env bash
# Install Skye's skills into Claude Code by symlinking each skill folder into
# ~/.claude/skills, and her global preferences (global/CLAUDE.md) to
# ~/.claude/CLAUDE.md.
#
# A symlink is a pointer to the real folder, so the skills keep living in this
# repo: editing a skill here, or running `git pull`, updates it everywhere at
# once with nothing to copy. Re-run this script after adding, renaming or
# removing a skill. Skills and CLAUDE.md alike follow whichever branch is
# checked out here.
#
# Usage:
#   ./install.sh                     link every skill (except skills/in-progress/)
#                                    and the global CLAUDE.md
#   ./install.sh ship merge          link only the named skills (not CLAUDE.md)
#   ./install.sh --dry-run [names]   show what would happen, change nothing
#   ./install.sh --uninstall         remove every link that points into this repo
#
# SKILLS_DIR=/some/folder ./install.sh   links skills somewhere else (used by the tests)
# CLAUDE_MD=/some/file ./install.sh      links the global CLAUDE.md there instead
#
# Personal skills (the ones this links) override a project's own skill with
# the same name, so linking `ship` hides a project's .claude/skills/ship.

# Stop on the first error, on unset variables, and on failures inside pipes.
set -euo pipefail

# The repo is wherever this script lives, so it works from any folder.
REPO="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"
# Skye's global preferences, linked like a skill so they have history too.
CLAUDE_MD="${CLAUDE_MD:-$HOME/.claude/CLAUDE.md}"
GLOBAL_SRC="$REPO/global/CLAUDE.md"

dry_run=false
uninstall=false
wanted=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --uninstall) uninstall=true ;;
    # Print the comment at the top, up to its first blank line, so it can grow.
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "Unknown option: $arg (try --help)" >&2; exit 2 ;;
    *) wanted+=("$arg") ;;
  esac
done

# Run a command, or only print it in --dry-run mode.
run() {
  if $dry_run; then echo "  (dry run) $*"; else "$@"; fi
}

# --- Uninstall --------------------------------------------------------------
# Only symlinks that point into this repo are ours. Anything else in
# SKILLS_DIR (a real folder, or a link installed by another tool, such as
# find-skills) is left alone.
if $uninstall; then
  # The global CLAUDE.md first, since the skills part can stop early.
  if [ -L "$CLAUDE_MD" ] && [[ "$(readlink "$CLAUDE_MD")" == "$REPO"/* ]]; then
    echo "removing CLAUDE.md"; run rm "$CLAUDE_MD"
  fi
  [ -d "$SKILLS_DIR" ] || { echo "Nothing to uninstall: $SKILLS_DIR doesn't exist."; exit 0; }
  for link in "$SKILLS_DIR"/*; do
    [ -L "$link" ] || continue
    case "$(readlink "$link")" in
      "$REPO"/*) echo "removing $(basename "$link")"; run rm "$link" ;;
    esac
  done
  exit 0
fi

# --- Find the skills ------------------------------------------------------
# A skill is any skills/<bucket>/<name>/ folder holding a SKILL.md.
# in-progress/ holds drafts, so it's never installed.
names=()
srcs=()
for skill_md in "$REPO"/skills/*/*/SKILL.md; do
  [ -e "$skill_md" ] || continue          # the glob matched nothing
  src="$(dirname "$skill_md")"
  case "$src" in "$REPO"/skills/in-progress/*) continue ;; esac
  name="$(basename "$src")"

  # Claude Code finds a skill by folder name, so two buckets can't both have
  # one called, say, "review". Catch that here rather than link one silently.
  for existing in ${names[@]+"${names[@]}"}; do
    if [ "$existing" = "$name" ]; then
      echo "Error: two skills are named '$name'. Rename one; names must be unique across buckets." >&2
      exit 1
    fi
  done
  names+=("$name")
  srcs+=("$src")
done

# Every name asked for on the command line must be a real skill.
for want in ${wanted[@]+"${wanted[@]}"}; do
  found=false
  for name in "${names[@]}"; do [ "$name" = "$want" ] && found=true; done
  $found || { echo "Error: no skill named '$want' (in-progress skills can't be installed)." >&2; exit 1; }
done

# --- Link them ----------------------------------------------------------------
run mkdir -p "$SKILLS_DIR"
problems=0

for i in "${!names[@]}"; do
  name="${names[$i]}"
  src="${srcs[$i]}"
  target="$SKILLS_DIR/$name"

  # With names given, skip every other skill.
  if [ ${#wanted[@]} -gt 0 ]; then
    match=false
    for want in "${wanted[@]}"; do [ "$want" = "$name" ] && match=true; done
    $match || continue
  fi

  if [ -L "$target" ]; then
    current="$(readlink "$target")"
    if [ "$current" = "$src" ]; then
      echo "ok       $name (already linked)"
    elif [[ "$current" == "$REPO"/* ]]; then
      # Ours, but stale: the skill moved to another bucket. Point it at the new place.
      echo "relink   $name -> $src"
      run ln -sfn "$src" "$target"
    else
      # Someone else's link. Replacing it could break another tool, so ask a human.
      echo "SKIPPED  $name: $target already links to $current" >&2
      problems=$((problems + 1))
    fi
  elif [ -e "$target" ]; then
    # A real folder or file: possibly a hand-written skill. Never overwrite it.
    echo "SKIPPED  $name: $target already exists and isn't a link from this repo" >&2
    problems=$((problems + 1))
  else
    echo "link     $name -> $src"
    run ln -s "$src" "$target"
  fi
done

# --- Link the global CLAUDE.md -------------------------------------------------
# Only on a full install: naming skills means "only these", and trying a
# branch's new skill shouldn't swap Skye's preferences in every project.
# Whatever is in the way holds preferences not yet in the repo, so replacing it
# could lose them. Say how to move them in instead. (diff follows a link.)
how_to_move_in() {
  echo "         To move it into this repo, copy any changes into global/CLAUDE.md" >&2
  echo "         (diff \"$CLAUDE_MD\" \"$GLOBAL_SRC\"), then remove it and run this again." >&2
  problems=$((problems + 1))
}

if [ ${#wanted[@]} -eq 0 ]; then
  if [ -L "$CLAUDE_MD" ] && [ "$(readlink "$CLAUDE_MD")" = "$GLOBAL_SRC" ]; then
    echo "ok       CLAUDE.md (already linked)"
  elif [ -L "$CLAUDE_MD" ]; then
    # Someone else's link, which another tool may rely on.
    echo "SKIPPED  CLAUDE.md: $CLAUDE_MD already links to $(readlink "$CLAUDE_MD")" >&2
    how_to_move_in
  elif [ -e "$CLAUDE_MD" ]; then
    # Skye's own file, from before it lived here.
    echo "SKIPPED  CLAUDE.md: $CLAUDE_MD is a real file, not a link to global/CLAUDE.md." >&2
    how_to_move_in
  else
    echo "link     CLAUDE.md -> $GLOBAL_SRC"
    run mkdir -p "$(dirname "$CLAUDE_MD")"
    run ln -s "$GLOBAL_SRC" "$CLAUDE_MD"
  fi
fi

# Report links into this repo whose skill no longer exists (renamed or
# deleted), so they don't linger as broken skills.
if [ -d "$SKILLS_DIR" ]; then
  for link in "$SKILLS_DIR"/*; do
    if [ -L "$link" ] && [[ "$(readlink "$link")" == "$REPO"/* ]] && [ ! -e "$link" ]; then
      echo "stale    $(basename "$link"): its skill is gone. Remove with: rm \"$link\"" >&2
    fi
  done
fi

if [ $problems -gt 0 ]; then
  echo "$problems item(s) skipped. Move or remove what's in the way, then run this again." >&2
  exit 1
fi
