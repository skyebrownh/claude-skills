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
- **An issue is a parent** (step 1 of [finding-the-parent.md](../ship/finding-the-parent.md)). Parents hold no work of their own: build their children.
- **An issue is blocked by an open issue:** `gh api repos/{owner}/{repo}/issues/<N>/dependencies/blocked_by --jq '.[] | select(.state == "open") | "#\(.number) \(.title)"'`. Name each blocker. One exception, the **sibling rule**: if the issue and its blocker are both children of the same "one PR" parent (see step 2), the blocker counts as landed once it's folded into the parent's branch (step 4 of [finding-the-parent.md](../ship/finding-the-parent.md)).
- **One listed issue blocks another.** They can't be built side by side, because one needs the other's work. Say to build the blocker first, and the other once the blocker has landed (or, for siblings, been committed on the parent's branch).

**An issue's branch already exists** (step 2 gives its name; check with `git branch --list <branch>`): this isn't a stop, but ask Skye, for every such branch at once, whether to carry on from it. It may hold a build that stopped part-way, or a different piece of work.

**A worktree is left over at `.claude/worktrees/<N>`** (`git worktree list`), from a build that stopped: ask whether to carry on in it or remove it (`git worktree remove`), because `git worktree add` can't reuse the path.

**An existing branch is checked out in this folder** and more than one issue is listed: git won't check one branch out in two folders, so ask Skye to switch this folder to another branch first.

**Several issues' plans change the same file:** this isn't a stop either, because the issues still build in parallel. Compare the approved plans' `### Files` lists, and for each path in more than one:

- **Name the section each plan changes there,** from the file's headings and the plan's entry. When the entry's wording matches no heading, say "section not clear from the plan".
- **Where two plans add to the same list or table, give each issue a spot**, e.g. the first listed adds at the end, and the next right after a named entry nearer the top. Git combines two changes only when at least one unchanged line sits between them, and the subagents can't see each other's work, so they can't keep apart on their own.

Show Skye each shared file, with its sections and spots, before starting the build, so she can stop it if she'd rather build them one at a time. Step 3 tells each subagent about them.

This step is done when every issue passes, Skye has answered about any branch or worktree that already exists, and she's been shown any shared files.

## 2. Work out each branch and its base

The branch is `<N>-<slug>`, where the slug is 2 to 4 lowercase words from the issue's title, joined by hyphens (e.g. `8-handover`).

The base is where the branch starts:

- **Usually** the default branch as it is on GitHub: run `git fetch origin <default branch>` once, and use `origin/<default branch>`. Starting from GitHub's copy means the branch includes everything merged so far, even if this folder's copy is behind.
- **A child of a "one PR" parent:** the parent's branch. Find the parent, its **Ships as** and its branch with [finding-the-parent.md](../ship/finding-the-parent.md). A child of a "one PR per child" parent uses the default branch, like a single issue.
  - **The parent has no branch yet:** create it first, with `git branch --no-track <P>-<slug> origin/<default branch>`, the slug coming from the parent's title.

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

   For an issue whose plan shares a file with another's (step 1), add this to its brief, once per shared file:

   > #<other N> (<its title>) is being built at the same time and also changes <path>, in <its section, or its whole `### Files` entry when the section isn't clear>. Make your changes in <this issue's section>, and leave every line you aren't changing exactly as it is: don't reflow, reorder or reformat it. <Only when step 1 gave this issue a spot:> Add new entries <this issue's spot>, so at least one unchanged line sits between yours and the sibling's. In your report, say where in <path> you made each change, and anything you couldn't keep apart.

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

For each issue: its branch, the commit at its tip, and the link to its `## Handover` comment, or why it stopped and what to do. With several issues, also list each shared file from step 1: the section each plan named, where each subagent says it made its changes, and anything it couldn't keep apart. If no file was shared, say so. Then stop: Skye reviews each branch, asks for revisions, or runs `/ship`.

## Revisions

Skye asks for changes after reading a handover. Each round is new commits, then a new handover, which replaces the old one:

- **On the branch checked out in this folder:** make the change here, commit it, and follow `handover` again.
- **On another branch:** make the change in this folder too. Worktrees are only for step 3's parallel builds. First check `git status --porcelain`: if it prints anything, stop and ask Skye what it is, because switching would carry it along. Then note the current branch, `git switch <branch>`, make the change, commit it, follow `handover`, and `git switch` back to the branch you noted.
- **A conflict with the default branch** (its PR is `CONFLICTING`, often after a sibling merged): that's a round too. Follow [fixing-conflicts.md](../merge/fixing-conflicts.md).

A round is done when its commits are on the branch and the new handover is posted.
