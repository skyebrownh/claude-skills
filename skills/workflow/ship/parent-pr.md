# Ship on a parent's branch

Step 1 of [SKILL.md](SKILL.md) sends you here when the branch belongs to a parent #P whose **Ships as** is `one PR`. Each child is committed on this branch, one `/ship <child#>` at a time. Then a plain `/ship` pushes the branch and opens one PR that closes the parent and every child. The checks in step 0 and the start of step 1 have already passed. Put each step below on the task list.

## 1. Find the children and their commits

```sh
gh api --paginate repos/{owner}/{repo}/issues/<P>/sub_issues --jq '.[] | "#\(.number)\t\(.state)\t\(.title)"'
git log --format=%s <default>..HEAD
```

A child **has a commit** when one of those subjects is its title exactly, or its title followed by ` (follow-up)`. Matching by title works because the commit message rule makes every child's first commit its title.

- A child number was given (`/ship <C>`): go to step 2.
- No number: go to step 3.

## 2. Commit one child (`/ship <C>`)

Stop at the first of these:

- **#C isn't in the sub-issue list.** It isn't a child of #P, so it doesn't belong on this branch.
- **#C isn't open.**
- **#C is blocked by an open issue.** List them with `gh api repos/{owner}/{repo}/issues/<C>/dependencies/blocked_by --jq '.[] | select(.state == "open") | "#\(.number) \(.title)"'`. Ignore a blocker that is a child of #P and already has a commit here: it stays open until this branch's PR merges, so it can't close sooner. Stop for any other open blocker, and name it.
- **There's nothing to commit.**
- **This conversation has no handover for #C.** Offer to give it, then wait for Skye to review it and run `/ship <C>` again. (For now the handover lives in the conversation. `/handover`, #8, will move it to a comment on the issue.)

Then follow steps 2 and 3 of [SKILL.md](SKILL.md) (stage only the files in #C's handover, re-run the checks), and commit:

```sh
git commit -F - <<'EOF'
<child title>

Part of #<P>

Co-Authored-By: <the co-author line>
EOF
```

**If #C already has a commit here,** this one is a follow-up, for example a fix found while working on a later child. Use the subject `<child title> (follow-up)`, and put one line on what changed and why before `Part of #<P>`. Always make a new commit, and leave the earlier one as it is: committed history is never rewritten.

Run `git log --oneline -1` and `git status --short` to show the commit and confirm nothing reviewed was left behind.

**Don't push.** The branch is pushed once, with every child, when the PR opens. Report the commit, and list each child that still has no commit. Then stop.

## 3. Open the parent PR (`/ship` with no number)

Stop if:

- **A child has no commit.** List each one, with `/ship <C>` to run for it. If one is already closed (shipped some other way, or dropped), ask whether to leave it out of this PR.
- **There are uncommitted changes** (`git status --short`). Ask which child they belong to: they need a `/ship <C>` first, or they don't belong on this branch.

Then follow these steps of [SKILL.md](SKILL.md):

1. Step 3: re-run the checks on the whole branch.
2. Step 5: push.
3. Step 6: open the PR, with the changes below.
4. Step 7: check it and hand back. Say that merging closes #P and every child.

Changes to step 6 for a parent PR:

- **First lines:** `Closes #P`, then a `Closes #C` line for each child, so merging closes all of them.
- **What changed:** one sentence on the parent's directive. Then a `### #C <child title>` heading for each child, with its files and a short note on each. Take these from #C's handover, or from `git show --stat` of its commits if this conversation doesn't have it.
- **Differences from the approved plan:** for each child that has a plan comment.
- **Acceptance criteria:** a `### #C <child title>` heading for each child, with its checklist copied word for word and ticked where done.
- **How to test:** a `### #C <child title>` heading for each child, with its handover's numbered steps. If this conversation doesn't have #C's handover, write "See the handover for #C."
- **Title:** the parent's title. If **Pull requests** says to copy the milestone and labels, use the parent's milestone, and every label from the parent and its children.
