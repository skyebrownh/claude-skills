# Fixing a branch that conflicts with the default branch

`/merge` sends you here for each open PR that conflicts with the default branch, usually because a sibling merged first and changed the same lines. `build`'s Revisions sends you here when Skye asks for that fix as a round. The steps are here once, so the two can't drift apart. Put each step below on the task list.

The fix happens **in this folder, on the issue's branch**: merge the default branch in, resolve, check, commit, hand over, and switch back. It never pushes: Skye reviews the new handover and runs `/ship <N>`, which pushes to the open PR.

- **Merge, never rebase or force-push.** Committed history is never rewritten, and the PR's branch is already on GitHub.
- **No worktree.** Worktrees are only for `/build`'s parallel step. One fix at a time here keeps every commit visible in Skye's folder.
- **No OK before committing.** The merge commit is reviewed in the new handover, like any other commit, and nothing is pushed until `/ship`.

## 1. Check first

Run `git status --porcelain`. **Anything is uncommitted or untracked:** stop, and ask Skye what it is. Switching branches would carry it onto the issue's branch.

Note the branch this folder is on (`git branch --show-current`), to switch back to at the end. The issue's number is the one the PR's branch name starts with (`<N>-<slug>`).

```sh
git fetch origin
```

**The PR's branch on GitHub has commits the local copy lacks** (it was pushed from another clone): `git merge-base --is-ancestor origin/<branch> <branch>` fails. Stop and report it, because a merge on the old copy would split the branch in two. With no local copy at all, `git switch <branch>` in step 2 makes one from `origin/<branch>`, so there's nothing to compare.

This step is done when the folder is clean and you know the branch to fix and the branch to come back to.

## 2. Merge the default branch in

```sh
git switch <branch>
git merge --no-commit origin/<default branch>
```

`--no-commit` stops before committing even when the merge is clean, so the checks in step 3 run before anything is committed.

Resolve each conflicted file (`git diff --name-only --diff-filter=U` lists them):

- **Both sides are wanted** (two additions next to each other, or changes to different parts of a line's meaning): keep both.
- **They can't both stay:** pick the one that fits both issues' plans best, and note why. Don't stop to ask: the commit body records the choice, and Skye reviews it in the handover.

`git add` each file once it's resolved, by name.

This step is done when `git diff --name-only --diff-filter=U` prints nothing.

## 3. Run the checks

Run every command under **Checks before committing** in `.claude/workflow.md`. A merge can combine cleanly and still break.

**A check fails:** fix it if the fix is part of resolving the conflict, and run the checks again. **It can't be fixed that way:** undo the merge, so nothing is left uncommitted, then switch back, stop, and report what failed:

```sh
git merge --abort
git switch <the branch you noted>
```

Skip step 4. The branch is as it was before the fix, so Skye can decide how to resolve it, and then ask for the fix again.

This step is done when every check passes.

## 4. Commit, hand over, switch back

Write the message to a file in the scratchpad, then `git commit -F <file>`:

```text
Merge <default branch> into <branch>

<each conflicted file, and what was kept and why>

Co-Authored-By: <the co-author line>
```

Then follow `handover` on this branch. It posts a new `## Handover` comment covering the merge commit, which replaces the old one.

Switch back: `git switch <the branch you noted>`. In Skye's skills repo this matters more than elsewhere, because installed skills run from whatever branch is checked out there.

This step is done when the handover is posted and the folder is back on the branch you noted. Tell Skye the handover's link and to run `/ship <N>` once she's reviewed it.
