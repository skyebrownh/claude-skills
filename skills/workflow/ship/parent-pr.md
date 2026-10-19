# Ship a parent that ships as one PR

[SKILL.md](SKILL.md) sends you here for a parent #P whose **Ships as** is `one PR`. Its children are built on their own branches, cut from #P's branch. `/ship <C>` **folds** each child's branch into #P's branch as one commit. Then `/ship <P>` (or a plain `/ship` on #P's branch) pushes #P's branch and opens one PR that closes #P and every child. Steps 0 to 3 of SKILL.md have already passed. Put each step below on the task list.

Find #P's branch, and whether a child is folded, with [finding-the-parent.md](finding-the-parent.md).

## Fold a child (`/ship <C>`)

Step 2 of SKILL.md has already checked that #C isn't folded yet. Fold, starting from the branch this folder is on:

```sh
git switch <P's branch>
git merge --squash <C's branch>
```

`--squash` stages every change on #C's branch as one set, without committing, so the parent's branch gets one commit per child however many commits the child's build made.

**It reports a conflict:** a sibling folded since #C's branch was cut changed the same lines. Resolve each conflicted file, keeping both sides where both are wanted. Where they can't both stay, pick the one that fits both children's plans best, and note why. `git add` each file by name. The commit body below records each resolution, and Skye reviews it in the parent PR, so there's no stop for her OK.

Run every command under **Checks before committing** on the staged result, before committing. Step 3 of SKILL.md checked #C's branch alone, but the parent's branch may hold siblings folded since #C's branch was cut, and a merge can combine cleanly yet still break. **A check fails:** fix it if the fix is part of resolving the conflict. **It can't be fixed that way:** undo the fold, so nothing is left uncommitted, then switch back, stop, and report what failed:

```sh
git reset --merge
git switch <the branch you started on>
```

`git reset --merge` puts the parent's branch back as it was. (`git merge --abort` doesn't work here: a squash merge leaves no merge in progress for it to abort.)

Commit:

```sh
git commit -F - <<'EOF'
<C's title>

Part of #<P>

<only after a conflict: each conflicted file, and what was kept and why>

Co-Authored-By: <the co-author line>
EOF
```

Then delete #C's branch, and switch back:

```sh
git branch -D <C's branch>     # -D, because git doesn't count a squashed branch as merged
git switch <the branch you started on>
```

Deleting it is safe: its work is now the fold commit, and it was never pushed, so no copy exists on GitHub. If the branch you started on was #C's, switch to #P's branch instead.

**Don't push.** #P's branch is pushed once, with every child, when its PR opens.

This step is done when `git log --oneline -1 <P's branch>` shows the fold, and #C's branch is gone. Report it, and list each child that still has no fold.

## Open the parent PR (`/ship <P>`)

Step 2 of SKILL.md has already checked that every child is folded, or is folded earlier in this run. Then:

1. Re-run the checks on the whole branch: `git switch <P's branch>`, every command under **Checks before committing**, then switch back. Stop if any fails.
2. Push: `git push -u origin <P's branch>`.
3. Open the PR, following step 5 of [SKILL.md](SKILL.md), with the changes below. Skip this if step 2 of SKILL.md found #P's PR already open: the push has added the new commits to it.
4. Check it and hand back, following step 6 of SKILL.md. Say that merging closes #P and every child.

This step is done when #P's PR is open and its link is reported.

Changes to step 5 for a parent PR:

- **First lines:** `Closes #P`, then a `Closes #C` line for each child, so merging closes all of them.
- **What changed:** one sentence on the parent's directive. Then a `### #C <child title>` heading for each child, with its files and a short note on each, from that child's latest `## Handover` comment.
- **Differences from the approved plan:** for each child that has a plan comment.
- **Acceptance criteria:** a `### #C <child title>` heading for each child, with its checklist copied word for word and ticked where done.
- **How to test:** a `### #C <child title>` heading for each child, with the manual test steps from its latest handover comment.
- **Title:** the parent's title. If **Pull requests** says to copy the milestone and labels, use the parent's milestone, and every label from the parent and its children.
