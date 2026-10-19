# `/build`

Builds one or more approved issues, each on its own branch, committing as the work goes, then hands each over for your review. It never pushes.

For the exact steps, see its [SKILL.md](../../skills/workflow/build/SKILL.md).

## When to use it

Once an issue has a `## Plan (approved)` comment from `/plan-issue`. Only you start it: typing `/build <N>` is your approval to build to that plan and commit on the issue's branch.

- **One issue** (`/build 12`) builds right here, in this folder.
- **Several issues** (`/build 12 13 14`) build in parallel, each in its own worktree: a second folder checked out from the same repository, so each issue has its own files while every commit lands in the one repo.

For changes after a handover, just ask in chat. Those are revisions, not a new `/build`.

## What you'll see

1. It checks every issue before building any, and stops at the first problem: uncommitted changes in this folder, an issue with no approved plan, a parent issue (build its children instead), or an issue blocked by one still open.
2. It names each branch `<N>-<slug>`, starting from GitHub's copy of the default branch, or from the parent's branch for a child of a "one PR" parent.
3. It builds the plan test-first with `tdd`, committing after each green slice.
4. It runs `/handover` for each branch, which posts a `## Handover` comment on the issue.
5. It reports each branch, its tip commit and the handover link, then stops for your review.

With several issues, Claude starts one subagent per issue. The subagents only build and commit. Claude then hands each branch over itself, from its worktree, and removes the worktree once the handover is posted. The branch and its commits stay.

## Decisions it asks you about

- **A branch or worktree already exists** for an issue: carry on from it, or not. It may hold a build that stopped part-way.
- **Several plans change the same file:** it shows you each shared file, the section each plan changes, and where each issue should add new entries. You can stop it there if you'd rather build them one at a time.

## Gotchas

- **Commit or stash first.** It won't start with uncommitted or untracked files in this folder, because switching branches would carry them along.
- **One issue blocking another** in the same `/build` stops it. Build the blocker first, then the other once the blocker has landed.
- **A branch checked out here** stops a multi-issue build, because git won't check out one branch in two folders.
- **Revisions on another branch** are made in this folder: Claude switches to that branch, commits, hands over, and switches back.
- **Switch back to `main`** in this repo when you're done with a branch, because installed skills follow whatever is checked out.

## Why it works this way

- **It never pushes,** so every commit can still be reviewed, and revised with a new commit, before anyone else sees it. Pushing is `/ship`'s job: [shipping committed branches](../../decisions/2026-10-16-001711-shipping-committed-branches.md).
- **Handovers run in the main session,** because subagents can't start the reviewers `fresh-eyes` needs. The same file covers why `/build` makes its own worktrees and creates branches with `--no-track`: [building on branches](../../decisions/2026-10-15-221331-building-on-branches.md).
- **Parallel builds are briefed about shared files,** rather than stopped or run one at a time, so two branches rarely change the same lines: [briefing parallel builds](../../decisions/2026-10-19-030107-briefing-parallel-builds.md).
- **Revisions happen in this folder, not a worktree,** so every commit happens where you can see it: [fixing conflicts on the branch](../../decisions/2026-10-18-232724-fixing-conflicts-on-the-branch.md).
