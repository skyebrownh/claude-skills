#!/usr/bin/env bash
# Tests for install.sh. Run with: bash tests/test_install.sh
#
# Each test points install.sh at a fresh temporary SKILLS_DIR, so your real
# ~/.claude/skills is never touched.

set -uo pipefail   # no -e: a failing check should be reported, not end the run

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/install.sh"
GLOBAL_SRC="$REPO/global/CLAUDE.md"
passed=0
failed=0

# A full install also links the global CLAUDE.md. Point it at a throwaway path
# for every test, so no test can ever replace your real ~/.claude/CLAUDE.md.
# Tests about the global file set their own CLAUDE_MD on top of this.
scratch="$(mktemp -d "${TMPDIR:-/tmp}/claude-md-test.XXXXXX")"
trap 'rm -rf "$scratch"' EXIT
export CLAUDE_MD="$scratch/CLAUDE.md"

# Record one check: check "<description>" <command...>
check() {
  local what="$1"; shift
  if "$@"; then passed=$((passed + 1)); else failed=$((failed + 1)); echo "FAIL: $what"; fi
}

# A fresh, empty skills folder for each test.
fresh_dir() { mktemp -d "${TMPDIR:-/tmp}/skills-test.XXXXXX"; }

# The skills install.sh should find: every SKILL.md outside in-progress/.
expected_names() {
  for f in "$REPO"/skills/*/*/SKILL.md; do
    case "$f" in */skills/in-progress/*) continue ;; esac
    basename "$(dirname "$f")"
  done
}

# --- Installing everything links each skill to its folder in the repo ---------
dir="$(fresh_dir)"
SKILLS_DIR="$dir" "$INSTALL" >/dev/null 2>&1
check "install exits 0" [ $? -eq 0 ]
for name in $(expected_names); do
  check "$name is a symlink" [ -L "$dir/$name" ]
  check "$name points into the repo" [ -f "$dir/$name/SKILL.md" ]
done

# --- Running it again changes nothing and still succeeds -----------------------
out="$(SKILLS_DIR="$dir" "$INSTALL" 2>&1)"
check "second run exits 0" [ $? -eq 0 ]
check "second run reports 'already linked'" grep -q "already linked" <<<"$out"

# --- Uninstall removes our links and leaves other things alone ------------------
mkdir "$dir/hand-written"                    # a real skill folder, not ours
ln -s /somewhere/else "$dir/other-tool"      # a link made by another tool
SKILLS_DIR="$dir" "$INSTALL" --uninstall >/dev/null 2>&1
for name in $(expected_names); do
  check "uninstall removed $name" [ ! -e "$dir/$name" ]
done
check "uninstall kept a real folder" [ -d "$dir/hand-written" ]
check "uninstall kept another tool's link" [ -L "$dir/other-tool" ]
rm -rf "$dir"

# --- It never overwrites a real folder or someone else's link -----------------
dir="$(fresh_dir)"
mkdir "$dir/ship"                            # a real folder named like a skill
ln -s /somewhere/else "$dir/merge"           # another tool's link, same name
SKILLS_DIR="$dir" "$INSTALL" >/dev/null 2>&1
check "install exits 1 when something is in the way" [ $? -eq 1 ]
check "real folder untouched" [ ! -L "$dir/ship" ]
check "other link untouched" [ "$(readlink "$dir/merge")" = "/somewhere/else" ]
check "the rest still got linked" [ -L "$dir/writing-skills" ]
rm -rf "$dir"

# --- Naming skills installs only those ------------------------------------------
dir="$(fresh_dir)"
SKILLS_DIR="$dir" "$INSTALL" writing-skills >/dev/null 2>&1
check "named install exits 0" [ $? -eq 0 ]
check "named skill linked" [ -L "$dir/writing-skills" ]
check "other skills not linked" [ ! -e "$dir/ship" ]
SKILLS_DIR="$dir" "$INSTALL" no-such-skill >/dev/null 2>&1
check "unknown name exits 1" [ $? -eq 1 ]
rm -rf "$dir"

# --- --dry-run changes nothing --------------------------------------------------
dir="$(fresh_dir)"
rmdir "$dir"                                 # it shouldn't even create the folder
SKILLS_DIR="$dir" "$INSTALL" --dry-run >/dev/null 2>&1
check "dry run exits 0" [ $? -eq 0 ]
check "dry run created nothing" [ ! -e "$dir" ]

# --- A stale link (skill renamed or deleted) is reported -------------------------
dir="$(fresh_dir)"
ln -s "$REPO/skills/workflow/renamed-away" "$dir/renamed-away"
out="$(SKILLS_DIR="$dir" "$INSTALL" 2>&1)"
check "stale link reported" grep -q "stale    renamed-away" <<<"$out"
rm -rf "$dir"

# --- A full install links the global CLAUDE.md --------------------------------
dir="$(fresh_dir)"
md="$(fresh_dir)/CLAUDE.md"
SKILLS_DIR="$dir" CLAUDE_MD="$md" "$INSTALL" >/dev/null 2>&1
check "global: install exits 0" [ $? -eq 0 ]
check "global: CLAUDE.md is a symlink" [ -L "$md" ]
check "global: it points at global/CLAUDE.md" [ "$(readlink "$md")" = "$GLOBAL_SRC" ]
out="$(SKILLS_DIR="$dir" CLAUDE_MD="$md" "$INSTALL" 2>&1)"
check "global: second run exits 0" [ $? -eq 0 ]
check "global: second run reports it already linked" grep -q "ok       CLAUDE.md (already linked)" <<<"$out"
rm -rf "$dir" "$(dirname "$md")"

# --- Naming skills leaves the global CLAUDE.md alone ----------------------------
dir="$(fresh_dir)"
md="$(fresh_dir)/CLAUDE.md"
SKILLS_DIR="$dir" CLAUDE_MD="$md" "$INSTALL" writing-skills >/dev/null 2>&1
check "global: named install exits 0" [ $? -eq 0 ]
check "global: named install doesn't link it" [ ! -L "$md" ]
rm -rf "$dir" "$(dirname "$md")"

echo "$passed passed, $failed failed"
[ $failed -eq 0 ]
