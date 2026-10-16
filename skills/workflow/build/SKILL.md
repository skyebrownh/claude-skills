---
name: build
description: Build one or more approved issues, each on its own branch, committing as the work goes, then hand each over for review. One issue is built in this folder; several are built in parallel, one subagent each in a temporary worktree. Never pushes. Use only when Skye types /build.
disable-model-invocation: true
argument-hint: "<N> [<N> …]"
---

# Build approved issues

Skye typed `/build $ARGUMENTS`. **That is her approval to build** each issue to its approved plan, and to commit on its branch as the work goes. Nothing is pushed: the branches stay local until `/ship`, so every commit can still be reviewed, and revised with a new commit, before anyone else sees it.

Check everything first, and stop at the first problem, saying what's wrong and what to do. Put each step below on the task list.

## 0. Read the project's facts

Read `.claude/workflow.md` at the repo root. You need **Default branch** and **Checks before committing**.

- **It's missing, or a section you need still holds `<placeholders>`:** stop and say to run `/setup-project` first. Don't guess the commands.
- **The project is on an older version of the process:** its version is the number under **Process version** (1 if that section is missing), and the current version is the newest heading in [setup-project's migrations.md](../setup-project/migrations.md). If the project's is lower, stop. Name each migration it's missing and say to run `/setup-project`.

This step is done when you know the default branch and the checks.

## 1. Check every issue before starting any

Run `git status --porcelain`, then for each issue `gh issue view <N> --json title,state,body,comments`. Stop, before building anything, if:

- **This folder has uncommitted or untracked changes.** A build switches branches or adds worktrees, and either could tangle that work up with the new branch. Ask Skye what the changes are.
- **An issue isn't open.** Say so, and ask whether Skye meant another issue.
- **An issue has no `## Plan (approved)` comment.** The plan is what Skye approved; building without one builds something she hasn't agreed to. Plan it first.
- **An issue is a parent** (`gh api repos/{owner}/{repo}/issues/<N> --jq .sub_issues_summary.total` is above 0). Parents hold no work of their own: build their children.
- **An issue is blocked by an open issue:** `gh api repos/{owner}/{repo}/issues/<N>/dependencies/blocked_by --jq '.[] | select(.state == "open") | "#\(.number) \(.title)"'`. Name each blocker. One exception, the **sibling rule**: if the issue and its blocker are both children of the same "one PR" parent (see step 2), the blocker counts as landed once its commit is on the parent's branch, which is when `git log --format=%s <default branch>..<parent's branch>` has a subject that is the blocker's title. It stays open until the parent's PR merges, so its state can't tell you.
- **One listed issue blocks another.** They can't be built side by side, because one needs the other's work. Say to build the blocker first, and the other once the blocker has landed (or, for siblings, been committed on the parent's branch).

**An issue's branch already exists** (step 2 gives its name; check with `git branch --list <branch>`): this isn't a stop, but ask Skye, for every such branch at once, whether to carry on from it. It may hold a build that stopped part-way, or a different piece of work.

**A worktree is left over at `.claude/worktrees/<N>`** (`git worktree list`), from a build that stopped: ask whether to carry on in it or remove it (`git worktree remove`), because `git worktree add` can't reuse the path.

**An existing branch is checked out in this folder** and more than one issue is listed: git won't check one branch out in two folders, so ask Skye to switch this folder to another branch first.

This step is done when every issue passes, and Skye has answered about any branch or worktree that already exists.

## 2. Work out each branch and its base

The branch is `<N>-<slug>`, where the slug is 2 to 4 lowercase words from the issue's title, joined by hyphens (e.g. `8-handover`).

The base is where the branch starts:

- **Usually** the default branch as it is on GitHub: run `git fetch origin <default branch>` once, and use `origin/<default branch>`. Starting from GitHub's copy means the branch includes everything merged so far, even if this folder's copy is behind.
- **A child of a "one PR" parent:** the parent's branch. Find the parent with `gh api repos/{owner}/{repo}/issues/<N>/parent --jq .number` (a 404 means it has none) and its **Ships as** line, as `/ship` does. A child of a "one PR per child" parent uses the default branch, like a single issue.
  - The parent's branch is the local branch matching `<P>-*` (`git branch --list '<P>-*'`).
  - **None yet:** create it first, with `git branch --no-track <P>-<slug> origin/<default branch>`, the slug coming from the parent's title.
  - **More than one:** ask Skye which it is.

Every branch is created with `--no-track`. Without it, a branch created from `origin/<default branch>` would track the default branch, so a plain `git push` could send its work there.

This step is done when every issue has a branch name and a base.

## 3. Build

### One issue: build it here

```sh
git switch -c <branch> --no-track <base>    # or `git switch <branch>` to carry on from an existing one
```

Then build the approved plan, following `tdd`, and commit as you go:

- **After each green slice** (once its refactor is done and the tests pass), commit it, with a short plain message saying what the slice does and the co-author line that this conversation's attribution instructions give. Stage files by name, so nothing stray gets in.
- **In a project without automated tests,** commit each logical step once every command under **Checks before committing** passes.
- **Never push,** and never rewrite a commit. A mistake is fixed with a new commit.

When the plan is done, follow `handover`, then go to step 5.

### Several issues: one subagent each

1. Make sure `.claude/worktrees/` is a line in `.git/info/exclude`, and add it if it isn't. That file is this clone's own ignore list, never committed, and it stops the worktrees showing up as untracked files in Skye's folder.
2. For each issue, make a worktree on its branch, from the repo root:

   ```sh
   git worktree add .claude/worktrees/<N> -b <branch> --no-track <base>   # or without `-b … <base>`, naming <branch>, for an existing one
   ```

   A **worktree** is a second folder checked out from the same repository, so each issue has its own working files while every commit lands in the one repository.
3. Start one `general-purpose` subagent per issue, **all in one message**, so they run in parallel. They can't start subagents of their own, which is why the handovers wait for step 4. Give each this brief, filled in:

   > Build issue #<N> (<title>) in the git worktree at <absolute path of the worktree>, on branch <branch>. Work only in that folder: run every command there, and edit only files inside it. Here is the issue and its approved plan: <issue body and the `## Plan (approved)` comment>. Read <absolute path of tdd's SKILL.md> and follow it to build the plan. The checks are: <the commands under Checks before committing>. After each green slice, once its refactor is done and the tests pass, commit it, staging files by name, with a short plain message and this last line: <the co-author line>. Never push, never rewrite a commit, and don't write a handover. Anything the plan doesn't cover is out of scope: note it rather than build it. When you're done, report the branch tip (`git rev-parse HEAD`), each check's result with the test count, any tests the plan didn't foresee, and anything you noted as out of scope.

   `tdd`'s SKILL.md is at `../../guides/tdd/SKILL.md` from this skill's folder. Give its absolute path, because the subagent can't open this skill's files by name.

This step is done when every issue's work is committed on its branch, or you know why it stopped.

## 4. Hand over each branch (several issues)

As each subagent reports back, follow `handover` for its branch, **running every command in its worktree** rather than in Skye's folder, so her folder never switches branch under her. Pass the subagent's notes on unforeseen tests and out-of-scope ideas into the handover.

Once that handover is posted, remove the worktree. The branch and its commits stay in the repository:

```sh
git worktree remove .claude/worktrees/<N>
```

A subagent that stopped, or whose checks fail, gets no handover. Keep its worktree, and report why.

This step is done when every finished branch has a posted handover and its worktree is gone.

## 5. Report

For each issue: its branch, the commit at its tip, and the link to its `## Handover` comment, or why it stopped and what to do. Then stop: Skye reviews each branch, asks for revisions, or runs `/ship`.

## Revisions

Skye asks for changes after reading a handover. Each round is new commits, then a new handover, which replaces the old one:

- **On the branch checked out in this folder:** make the change here, commit it, and follow `handover` again.
- **On another branch:** make sure `.claude/worktrees/` is in `.git/info/exclude`, as in step 3, then make a worktree for it (`git worktree add .claude/worktrees/<N> <branch>`), and give a subagent the change to make and commit, as in step 3. Then hand it over from that worktree and remove it, as in step 4. Skye's folder stays on whatever branch she has checked out.

A round is done when its commits are on the branch and the new handover is posted.
