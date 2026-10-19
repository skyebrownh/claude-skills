# Fixing conflicts on the issue's branch

Issue: #43

Two issues built in parallel changed the same lines. Once the first merged, the second's PR conflicted with `main`, and the fix ended up as uncommitted changes in a worktree. That followed `build`'s Revisions rule for another branch, which clashed with worktrees being only for parallel builds. Now the fix is written once, in `merge/fixing-conflicts.md`, and both `/merge` and `build`'s Revisions point to it.

- **Revisions on another branch happen in this folder.** This replaces the "Revisions on another branch go to a subagent in a worktree" bullet in `2026-10-15-221331-building-on-branches.md`. The folder switches to the branch, makes the change, commits, hands over, and switches back, so every commit happens where Skye can see it. Worktrees stay for `/build`'s parallel step only.
- **`/merge` fixes the conflicts it causes.** After merging, it checks every open PR into the default branch and fixes each one now `CONFLICTING`, so Skye doesn't find out at that PR's own `/merge`. A PR that's already conflicting when `/merge` starts gets the same fix, and then `/merge` stops: the fix needs a handover and `/ship` before it can merge.
- **`/ship` warns ahead.** With several branches, it dry-runs a merge of each pair with `git merge-tree --write-tree`, which changes nothing, and names the pairs that will conflict. It doesn't stop, because the fix comes after the first merge anyway. A branch whose PR is already open is only pushed, which adds the fix to that PR.
- **Merge, don't rebase.** Committed history is never rewritten, and the branch is already on GitHub, so a rebase would need a force-push.
- **No OK before committing.** A merge commit is a commit like any other: Claude picks a resolution where both sides can't stay, the commit body records each one, and Skye reviews it in the new handover. Nothing is pushed until `/ship`. The same goes for a conflicting fold in `ship/parent-pr.md`.
- **Undo when the checks fail.** If the checks can't be fixed after resolving, the merge is undone (`git merge --abort`, or `git reset --merge` for a fold, which leaves no merge to abort), the folder switches back, and Claude reports what failed. Nothing is left uncommitted for a later step to trip over.
- **Switching back is a step.** Installed skills are symlinks into this repo, so whatever branch it has checked out is the version every project runs. A fix that left this folder on an issue's branch would leave every project running half-reviewed skills.

Left out: comparing plans' files or briefing parallel subagents about shared files (#44), overlap checks in `/plan-issue` and `/draft-issue`, and the desktop app's `sync_with_base_branch`.
