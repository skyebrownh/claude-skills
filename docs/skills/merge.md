# `/merge`

Merges an approved pull request, cleans up after it, closes any parent issue the merge finished, fixes other open PRs it left conflicting, and lists what to check after the deploy.

For the exact steps, see its [SKILL.md](../../skills/workflow/merge/SKILL.md), with [fixing-conflicts.md](../../skills/workflow/merge/fixing-conflicts.md) for conflicts.

## When to use it

Once a PR from `/ship` is ready and you want it in. Only you start it: typing `/merge <PR#>` is your approval to merge, and merging may deploy. Give the PR number; it won't guess one from the branch.

## What you'll see

1. It reads `.claude/workflow.md`. If merging deploys, it says where, in one line, before merging.
2. It checks the PR is open, not a draft, and aimed at the default branch, and that it closes an issue.
3. It merges in the style `workflow.md`'s **Merging** section gives (squash, rebase or a merge commit): one style for a single-issue PR, and one for a parent PR, which closes several issues.
4. It cleans up: updates the default branch, confirms nothing was left behind on the branch, deletes the local branch (and any worktree still using it), and checks each closed issue really closed.
5. It closes any `one PR per child` parent whose last child just closed, with a comment listing each child and its PR. If children are still open, it reports the parent's progress, such as "2 of 4 children still open".
6. It checks every other open PR. Any the merge left `CONFLICTING` it fixes on that PR's branch, in this folder, and hands over.
7. If merging deploys, it lists what to check after the deploy, from `workflow.md`. It suggests a release if `workflow.md` describes one. It never creates one.

## Decisions it asks you about

- **Which PR,** when you don't give a number.
- **How to proceed** when the PR closes no issue, or closes several when `workflow.md` says parent PRs aren't used.
- **What uncommitted changes in this folder are,** before it switches branches to clean up.

## Gotchas

- **`UNKNOWN` isn't a problem at first.** Just after a push or a merge, GitHub recalculates whether a PR can merge. It waits up to about a minute, and stops if it's still unknown.
- **A PR that's already `CONFLICTING`** isn't merged. It gets fixed, then `/merge` stops: review the new handover, run `/ship <N>` to push the fix, then `/merge` again.
- **After fixing other PRs,** each needs your review and `/ship <N>` before it can merge. The wrap-up gives each handover link.
- **It doesn't check the live site itself.** It lists what to check, and you check the deploy.
- **The remote branch is left alone** if GitHub didn't delete it. Deleting a remote branch needs your OK.

## Why it works this way

- **Check everything first, and stop at the first problem,** saying what's wrong rather than fixing it silently. These rules come from [the first version](../../decisions/2026-10-15-130821-first-version.md). Its SKILL.md adds that a failed merge stops before any clean-up, so nothing is deleted while the outcome is in doubt.
- **It stops when the project is behind** on its process version, rather than following facts that may no longer mean what it expects: [process versions and migrations](../../decisions/2026-10-15-181045-process-versions-and-migrations.md).
- **Branches are deleted with `-D`.** A squash or rebase merge makes new commits, so git doesn't recognise the branch as merged. The check that merging the branch again would add nothing comes first, so `-D` only deletes work that's already merged.
- **A release needs its own approval,** because it publishes a tag. Typing `/merge` approves the merge, not the release (also from the [first version](../../decisions/2026-10-15-130821-first-version.md)).
- **Closing a finished parent needs no second prompt.** It follows from how you chose to ship the parent, and a closed issue can be reopened: [closing finished parents](../../decisions/2026-10-17-205337-closing-finished-parents.md).
- **Conflicts are fixed by merging the default branch in, never by rebasing,** because history is never rewritten and the branch is already on GitHub. Fixing them right after the merge saves you finding out at that PR's own `/merge`: [fixing conflicts on the branch](../../decisions/2026-10-18-232724-fixing-conflicts-on-the-branch.md).
