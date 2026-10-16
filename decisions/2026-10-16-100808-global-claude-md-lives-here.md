# The global CLAUDE.md lives here

Issue: #11

`~/.claude/CLAUDE.md`, Skye's preferences for every project, moved into `global/CLAUDE.md` (#11), and `install.sh` links it like a skill.

- **It gets history and review,** like any skill. Before, it was edited by hand, so a change had no issue, no diff and no way back.
- **`install.sh` never replaces a real file there,** or another tool's link. It says how to move the file in instead (copy any changes across, remove it, run again), because replacing it could lose a change not yet copied into the repo.
- **Only a full install links it.** Naming skills means "only these", and the Manual test setup has Skye run `./install.sh <name>` to try a branch's new skill, which shouldn't also swap her preferences.
- **It follows the checked-out branch,** like the skills. A branch cut before #11 merged has no `global/CLAUDE.md`, so on one the link points at nothing and Claude Code runs without global preferences until she switches back.
- **Slimmed to what's true in every project:** tighter wording, the `--body-file` line dropped (the skills do it), and the Git rules merged with "ask before deleting" into one Approvals (always) section. The plan-first line and the review list stay until their own issues replace them.
- **`--help` prints the top comment up to its first blank line,** rather than a fixed line range, which the longer usage had outgrown.
