# Building on branches, in parallel

Issue: #19

Replaced in part by: [2026-10-18-232724-fixing-conflicts-on-the-branch](2026-10-18-232724-fixing-conflicts-on-the-branch.md): revisions on another branch are made in this folder, not by a subagent in a worktree.

`/build <N> …` (#19) builds approved issues on their own branches, committing each green slice, and ends with `/handover`. Several issues build at once, one subagent each in a worktree.

- **Handovers run in the main session,** not in the subagents. Subagents can't start subagents, and `fresh-eyes` needs two, so a subagent's own review would lose the fresh context that makes it worth having. Each subagent builds and commits; the main session hands each branch over, from its worktree.
- **`/build` makes the worktrees itself** with `git worktree add`, rather than through the Agent tool's `isolation: worktree`. That option picks its own branch name and base, and `/build` needs `<N>-<slug>` from the right base (the parent's branch, for a child of a "one PR" parent), and a worktree that lasts until its handover is posted.
- **Worktrees live in `.claude/worktrees/<N>`,** listed in `.git/info/exclude` (this clone's own ignore file, never committed), so they never show up as untracked files in Skye's folder.
- **Branches are created with `--no-track`.** A branch made from `origin/main` otherwise tracks `main`, so a plain `git push` could send its work there; `/ship` sets the real upstream when it pushes.
- **Build order follows blockers:** `/build` stops if one listed issue blocks another, rather than ordering them itself, because the blocked one needs the other's work to have landed (or, for siblings, been committed on the parent's branch) before it starts.
- **The sibling rule:** a child blocked by a sibling under the same "one PR" parent can be built once that sibling's commit is on the parent's branch, found by its title, because the sibling stays open until the parent's PR merges.
- **Revisions on another branch** go to a subagent in a worktree, so Skye's folder never switches branch under her while she reviews.
