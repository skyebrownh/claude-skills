---
name: ship
description: Push one or more issues' committed, handed-over branches and open their pull requests, or fold a child into its parent's branch when the parent ships as one PR. Running /ship is Skye's approval to push. Use only when Skye types /ship.
disable-model-invocation: true
argument-hint: "[<N> …] (none: the current branch's issue)"
---

# Ship issues' branches

Skye typed `/ship $ARGUMENTS`. **That is her approval to push** each issue's branch and open its pull request, or, for a child whose parent ships as one PR, to fold its branch into the parent's branch. The work is already committed, and she reviewed it from its handover. **Never merge.** Merging can deploy, and it needs `/merge` or her OK in chat.

The approval arrives as a typed command, possibly in a new session, so **check everything first**. Stop at the first problem, say what's wrong and what to do, and don't fix problems silently. Put each step below on the task list.

## 0. Read the project's facts

Read `.claude/workflow.md` at the repo root. You need these sections: **Default branch**, **Checks before committing**, **Pull requests** and **Merging**.

- **It's missing, or a section you need still holds `<placeholders>`:** stop and say to run `/setup-project` first. Don't guess the commands.
- **The project is on an older version of the process:** its version is the number under **Process version** (1 if that section is missing), and the current version is the newest heading in [setup-project's migrations.md](../setup-project/migrations.md). If the project's is lower, stop. Name each migration it's missing and say to run `/setup-project`, which applies them. Running on an old setup could follow facts that no longer mean what this skill expects.
- If the project's CLAUDE.md disagrees with `workflow.md`, stop and ask which is right.

This step is done when you have all four sections.

## 1. Work out which issues

- **Numbers were given:** ship those issues, in the order given.
- **No number:** use the current branch's issue, the number its name starts with (`<N>-<slug>`, from `git branch --show-current`). **On the default branch, or a branch whose name doesn't start with a number,** stop and ask which issue to ship.

This step is done when you have the list of issues, in order.

## 2. Check every issue before shipping any

Run `git status --porcelain` once. **Anything is uncommitted or untracked:** stop. `/ship` switches branches, which would carry those changes along, and only committed, handed-over work ships. Ask Skye what they are.

Then, for each issue, run `gh issue view <N> --json title,state,milestone,labels,body,comments`, and stop if:

- **It isn't open.**
- **It's blocked by an open issue:** `gh api repos/{owner}/{repo}/issues/<N>/dependencies/blocked_by --jq '.[] | select(.state == "open") | "#\(.number) \(.title)"'`. Ignore a blocker that is a sibling under the same "one PR" parent and is either already folded into the parent's branch (step 4 of [finding-the-parent.md](finding-the-parent.md)) or earlier in this list: it stays open until the parent's PR merges. Name any other open blocker, because the link says this work depends on it landing first.

### What kind of issue it is

Use [finding-the-parent.md](finding-the-parent.md), and stop where it says to.

| #N is | Ships as | What to do |
| --- | --- | --- |
| a parent | one PR | Its PR: [parent-pr.md](parent-pr.md), "Open the parent PR". |
| a parent | one PR per child | Stop. Its children each ship on their own; ship them by number. |
| a child of #P | one PR (#P's) | A fold: [parent-pr.md](parent-pr.md), "Fold a child". |
| a child of #P | one PR per child (#P's) | Carry on below. The PR also says `Part of #P`. |
| neither | | Carry on below, as a single issue. |

Then, before looking for any branch:

- **A child to fold is already folded** (step 4 of [finding-the-parent.md](finding-the-parent.md)): stop. Its branch was deleted by the fold, and a fix to a folded child is a new child issue, with its own plan and handover, so that every commit on the parent's branch has one reviewed reason.
- **A parent:** list its children (`gh api --paginate repos/{owner}/{repo}/issues/<P>/sub_issues --jq '.[] | "#\(.number)\t\(.state)\t\(.title)"'`). Stop if a child is neither folded nor earlier in this list, and name each one: it needs a handover and `/ship <C>` first. If one of them is closed (shipped some other way, or dropped), ask whether to leave it out of this PR.

### For every issue that isn't a parent

- **Its branch:** the local branch matching `<N>-*` (`git branch --list '<N>-*'`). **None:** stop, because there's nothing committed to ship. **More than one:** ask which.
- **Its handover:** the issue's latest comment that starts `## Handover`. Its **Covers** line names a commit id (older handovers give a short and a full one; use the full one, which can't be ambiguous). Expand it with `git rev-parse --verify --quiet '<id>^{commit}'`, and compare the result with `git rev-parse <branch>`.
  - **No handover comment:** stop. Without one there's no sign Skye reviewed the work. Offer to run `/handover`, and wait for her to review it and run `/ship` again.
  - **It doesn't expand** (no output: the commit isn't here, or the short id matches several): stop, and offer to run `/handover` again, so the new comment names a commit git can find.
  - **It covers another commit:** stop. The branch has moved on since the handover, so Skye may not have seen the newest commits. Offer to run `/handover` again.

Only the comment counts, never this conversation, so `/ship` works the same from any session.

### Open PRs and conflicts between branches

- **Its open PR:** for each branch to push (every issue except a fold), `gh pr list --head <branch> --state open --json number,url`. A branch with one already open was pushed before, and is now carrying a revision or a conflict fix, so step 4 only pushes it.
- **Branches that will conflict with each other:** when two or more branches will be pushed as PRs, dry-run merge each pair:

  ```sh
  git merge-tree --write-tree --name-only --no-messages <branch a> <branch b>
  ```

  It merges in memory and changes nothing. Exit code 1 means they conflict, and the lines after the first (a tree id) name the conflicting files. Note each pair and its files, but don't stop: both can still ship, and once the first merges, `/merge` fixes the second on its branch.

This step is done when every issue passes, and you know each one's kind, branch, handover and open PR, and any pairs that conflict.

## 3. Re-run the checks on each branch

Note the branch this folder is on (`git branch --show-current`). For each issue that isn't a parent:

```sh
git switch <branch>
<every command under Checks before committing, in order>
git switch <the branch you noted>
```

Note the test count for the PR. If any command fails or reports a problem, switch back, **stop**, and report it. Nothing has been pushed or folded yet.

This step is done when every branch passes and this folder is back on its branch.

## 4. Ship each issue, in order

- **A fold, or a parent PR:** follow [parent-pr.md](parent-pr.md).
- **A single issue, or a child of a "one PR per child" parent:** push, then open its PR (step 5), unless step 2 found one already open:

  ```sh
  git push -u origin <branch>
  ```

  `-u` sets the branch's upstream, so it now tracks its own branch on GitHub. The push adds the new commits to an open PR, so it needs no `gh pr create`.

This step is done when every issue to fold is folded, and every other branch is pushed and has a PR open, either one it already had or one from step 5.

## 5. Open the pull request

Write the description to a file in the scratchpad directory. Passing it with `--body-file` keeps quotes and backticks intact. Follow the template named under **Pull requests**. If the template is "none", use these same parts as headings:

- `Closes #N` on the first line, so merging closes the issue. For a child, `Part of #P` on the next line, so the PR links back to the parent.
- **What changed:** taken from the handover comment, with each file and a short note.
- **Differences from the approved plan,** if the issue has a plan comment and the build differs from it, said plainly.
- **Acceptance criteria:** the issue's checklist copied **word for word**, ticked where done, with the test count on the tests line (e.g. "(238 tests, 3 new)"). Leave anything not done unticked, with a short italic reason.
- **How to test:** the handover's manual test steps.
- **Checklist,** if the template has one: tick what applies, and for anything else leave it unticked with a reason.
- Keep any closing lines the template has, then the PR attribution line from this conversation's instructions.

```sh
gh pr create --title "<issue title>" --body-file <file> --base <default branch> --head <branch>
```

If **Pull requests** says to copy the milestone and labels, add `--milestone "<issue's milestone>"` and a `--label <label>` for each of the issue's labels.

This step is done when `gh pr create` prints the PR's link.

## 6. Check each PR and hand back

Use the PR from step 5, or the one step 2 found open:

```sh
gh pr view <PR> --json number,url,mergeable,mergeStateStatus
```

`mergeable` can read `UNKNOWN` for a few seconds after a PR is created. Check again shortly rather than reporting it as a problem.

Report briefly, for each issue:

- **a PR:** the branch pushed, the PR link (and whether it's new or was already open), its milestone and labels, whether GitHub says it can merge, and any criterion left unticked, with why;
- **a fold:** the fold commit (short id and title) on the parent's branch, and which children still have no fold.

Then name each pair from step 2 that will conflict, with its files, and say that the second to merge will need a fix after the first lands, which `/merge` makes.

Then say what merging will do, from **Merging**. For a child of a `one PR per child` parent, add that merging closes the child, and that its parent closes once its last child merges. If merging deploys, say so plainly, even when a PR doesn't change the running app. Skye approves with `/merge <PR#>` or by saying so in chat.

This step is done when every issue is reported. Then stop. Don't merge.
