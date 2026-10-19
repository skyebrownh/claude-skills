# `/ship`

Pushes the committed, handed-over branch for one or more issues and opens each one's pull request. For a child whose parent ships as one PR, it folds the child's branch into the parent's branch instead. It never merges.

For the exact steps, see its [SKILL.md](../../skills/workflow/ship/SKILL.md), with [finding-the-parent.md](../../skills/workflow/ship/finding-the-parent.md) and [parent-pr.md](../../skills/workflow/ship/parent-pr.md) for parents and children.

## When to use it

After you've reviewed a branch from its latest handover and are happy with it. Only you start it: typing `/ship` is your approval to push.

- **`/ship`** ships the current branch's issue.
- **`/ship 12 13`** ships those issues, in that order.
- **After a revision or a conflict fix** to a branch whose PR is already open, `/ship <N>` only pushes, which adds the new commits to that PR.

## What you'll see

1. It checks every issue before shipping any: nothing uncommitted, each issue open and not blocked, and a local `<N>-*` branch for each issue that isn't a parent.
2. It reads each issue's latest `## Handover` comment and checks that its **Covers** commit is the branch tip.
3. With several branches, it dry-runs a merge of each pair and notes which ones will conflict. That changes nothing, and doesn't stop the ship.
4. It re-runs the project's checks on each branch, then switches back to the branch you were on.
5. It pushes each branch and opens its PR, filled in from the project's PR template, the handover and the issue's acceptance criteria.
6. It reports each PR's link and whether GitHub says it can merge, names the pairs that will conflict, and says what merging will do (including whether it deploys). Then it stops.

### Parents and children

Bigger work is a **parent** issue with **children**. The parent holds no work of its own; its `**Ships as:**` line says how the children become PRs, and `/ship` reads it every time.

**`one PR per child`:** each child is a thin slice that works on its own, with its own branch and PR. `/ship <child>` ships it like a single issue, and the PR also says `Part of #P`. `/ship <parent>` stops, because there's nothing to ship there.

**`one PR`:** all the children end up in one PR, on the parent's branch. It takes two kinds of `/ship`:

1. **`/ship <child>` folds the child.** Each child was built on its own branch, cut from the parent's branch. Folding squashes that branch into **one commit** on the parent's branch, titled with the child's title, however many commits the build made. It then deletes the child's branch, and pushes nothing.
2. **`/ship <parent>` opens the PR,** once every child is folded or comes earlier in the same `/ship`. It pushes the parent's branch once and opens one PR that closes the parent and every child, with a section per child.

How it knows a child is folded: it looks for a commit on the parent's branch whose subject is the child's title. The child's own state can't tell it, because the child stays open until the parent's PR merges.

**A fold that conflicts** (a sibling folded earlier changed the same lines) is resolved by Claude, keeping both sides where it can. The fold commit's message records each choice, and you review it in the parent PR. The checks run on every fold before it's committed. If they fail and the fix isn't part of resolving a conflict, it undoes the fold and stops.

## Decisions it asks you about

- **No issue number on a branch without one** (or on the default branch): which issue to ship.
- **More than one local `<N>-*` branch:** which one.
- **A closed child** when opening a parent's PR: whether to leave it out.

It never decides how a parent ships. With no `Ships as:` line, or one it doesn't recognise, it stops and asks you to set it on the parent.

## Gotchas

- **No handover, or one for an older commit:** it stops and offers to run `/handover`. Review the new one, then run `/ship` again.
- **A folded child can't be re-shipped.** Its branch is gone and its work is the fold commit. A fix to it is a new child issue, with its own plan and handover.
- **A parent with unfolded children** stops, and names each child that needs a handover and `/ship <child>` first.
- **A blocker is ignored** only when it's a sibling under the same "one PR" parent that's already folded, or earlier in the same `/ship`. Any other open blocker stops it.
- **A pair that will conflict** can still ship. Once the first merges, `/merge` fixes the second on its branch.
- **`mergeable` reads `UNKNOWN`** for a few seconds after a PR opens. That's GitHub recalculating, not a problem.

## Why it works this way

- **The handover comment is the proof of review,** so `/ship` works from any session and a commit added after review stops it. The same file covers squash-folding children and why a folded child's fix is a new issue: [shipping committed branches](../../decisions/2026-10-16-001711-shipping-committed-branches.md). Its rule that a fold conflict waits for you was later replaced by [fixing conflicts on the branch](../../decisions/2026-10-18-232724-fixing-conflicts-on-the-branch.md).
- **`Ships as:` is your call,** and with no line it stops rather than guess: [parent and child issues](../../decisions/2026-10-15-172511-parent-and-child-issues.md).
- **It warns about conflicting pairs, and only pushes when a PR is open,** because the fix comes after the first merge anyway: [fixing conflicts on the branch](../../decisions/2026-10-18-232724-fixing-conflicts-on-the-branch.md).
