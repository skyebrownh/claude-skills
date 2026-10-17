---
name: whats-next
description: Recommend what to work on next, from a clean and up-to-date default branch: one subagent reads the open issues and picks the next one, with the command to run. Use only when Skye types /whats-next.
disable-model-invocation: true
argument-hint: "(no arguments)"
---

# Recommend what to work on next

Skye typed `/whats-next`. **That is her approval to read the open issues and recommend one; it changes nothing.** No issue, label, comment or file is edited, and the command it recommends is hers to type.

It's for picking a project back up after a break or a finished piece of work, so it assumes she's starting from a clean, up-to-date default branch, and checks that rather than reporting on anything else locally. Check everything first, and stop at the first problem, saying what's wrong and what to do. Put each step below on the task list.

This skill needs no `.claude/workflow.md`, so it works in any project with GitHub issues.

## 0. Read the project's facts

The default branch is under **Default branch** in `.claude/workflow.md`. If there's no such file or section, or it still holds a `<placeholder>`, ask GitHub: `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`.

This step is done when you know the default branch.

## 1. Check the start

Run `gh auth status`, then `git fetch --quiet --prune origin`. Fetching only updates git's copy of GitHub's branches, never Skye's files. Without it, "behind" would be measured against a stale copy, and the subagent would see branches deleted on GitHub but miss ones pushed from elsewhere. Stop if:

- **`gh` isn't signed in, or the repo has no GitHub remote:** the issues can't be read. Say to run `gh auth login`, or that this skill needs a GitHub repo.
- **The current branch isn't the default branch** (`git branch --show-current`): say to `git switch <default branch>`. A recommendation made from a feature branch would start the next piece of work from the wrong place.
- **There are uncommitted or untracked changes** (`git status --porcelain` prints anything): say to commit or stash them first.
- **The default branch is behind GitHub's** (`git rev-list --count HEAD..origin/<default branch>` is above 0): say to `git pull`, so the next build starts from everything merged so far.

This step is done when every check passes.

## 2. Ask one subagent

Start one subagent with `subagent_type: Explore`, so the issues' bodies and comments stay out of this conversation. Subagents can't open this skill's files, so paste this brief into its prompt, filled in:

> In the git repo at <absolute path of the repo root>, whose default branch is <default branch>, recommend which open issue to work on next. Run every command from that folder.
>
> **Pass 1, cheap, every open issue.** Run:
>
> - `gh api --paginate 'repos/{owner}/{repo}/issues?state=open&per_page=100' --jq '.[] | select(.pull_request | not) | {number, title, labels: [.labels[].name], blocked_by: .issue_dependencies_summary.blocked_by, children: .sub_issues_summary.total}'`
> - `git branch -a --format='%(refname:short)'`: a branch named `<N>-<slug>` (or `origin/<N>-<slug>`) is issue N's.
> - `gh pr list --state open --json number,headRefName`
> - `gh issue list --state open --limit 200 --search '"Plan (approved)" in:comments' --json number`: issues that probably have a plan.
>
> An issue with children above 0 is a parent: it holds no work of its own. List its children (`gh api repos/{owner}/{repo}/issues/<N>/sub_issues --jq '.[] | "#\(.number) \(.state) \(.title)"'`) in their listed order, and read the line in its body that starts `**Ships as:**` (`gh issue view <N> --json body`).
>
> - **Ships as `one PR per child`, or it has no `<N>-*` branch:** never list the parent. Its children are ranked like any other issue.
> - **Ships as `one PR`, with a `<N>-*` branch:** the parent is started work. Each child is built on its own branch and then **folded** into the parent's branch by `/ship`, which deletes the child's branch but leaves the child open until the parent's PR merges. A child is folded when `git log --format=%s <default branch>..<parent's branch> | grep -Fx '<child title>'` prints its title. Never list a folded child: its work is done. Then the parent's own stage is:
>
> | Parent's stage | How it's recognised | Command |
> |---|---|---|
> | children to finish | an open child isn't folded yet | list that child in its place, staged as usual |
> | ready for its PR | every open child is folded, and no PR from the parent's branch | `/ship <N>` |
> | ready to merge | an open PR from the parent's branch | `/merge <PR#>` |
>
> **Shortlist about 5 issues,** in this order:
>
> 1. Work already started: an issue with a branch, an open PR, a handover, or a plan.
> 2. Bugs (a `bug` label).
> 3. The first open child of each open parent, in the parent's order.
> 4. Your judgement from the titles and labels, such as an issue others depend on.
>
> An issue with blocked_by above 0 goes after its open blockers (`gh api repos/{owner}/{repo}/issues/<N>/dependencies/blocked_by --jq '.[] | select(.state == "open") | "#\(.number) \(.title)"'`). If a blocker isn't on the shortlist, it takes the blocked issue's place. Children of the same parent always keep the parent's order between them, even when a later one is already started, because the parent's order is the plan for that work.
>
> **Pass 2, shortlist only.** Read each one's comments (`gh issue view <N> --json comments`), and give it a stage. The latest `## Plan (approved)` or `## Handover` comment is the one that counts. A handover's **Covers** line names a commit (older handovers give a short and a full id; use the full one): expand it with `git rev-parse --verify --quiet '<id>^{commit}'` and compare with `git rev-parse <branch>`.
>
> | Stage | How it's recognised | Command |
> |---|---|---|
> | needs a plan | no `## Plan (approved)` comment | `/plan-issue N` |
> | ready to build | a plan, no `N-*` branch | `/build N` |
> | being built | an `N-*` branch, no handover covering its tip | finish the build, then `/handover` |
> | in review | the latest handover covers the branch tip, and no PR | review it, then `/ship` |
> | ready to merge | an open PR from the `N-*` branch | `/merge <PR#>` |
>
> Report exactly in this form, with at most 5 issues in all, and nothing else:
>
> ```
> NEXT: #<N> <title> | <stage> | <command> | <why it's next, one sentence>
> THEN: #<N> <title> | <stage> | <command> | <why, one short clause>
> UNRANKED: <number of open issues, parents included, not listed above>
> ```
>
> with 0 to 4 THEN lines. With no issue to recommend, report `NEXT: none` and the UNRANKED line. Read only: change no files, and never edit, label or comment on an issue. Under 300 words.

This step is done when the report is back in that form. If it isn't, or it lists more than 5 issues, ask the same subagent to fix it.

## 3. Report

Show Skye:

- **Next:** the NEXT issue's number and title (as a link), its stage, why it's next, and its command, on a line of its own so she can copy it.
- **Then:** each THEN line, one line each, in order.
- **The rest:** "<UNRANKED> other open issues not ranked", left out when it's 0.

With `NEXT: none`:

- **UNRANKED is 0:** say there are no open issues, and that the next step is `/draft-issue` with an idea.
- **UNRANKED is above 0:** say none of the open issues can be picked (for example, only parents whose children are all closed), and suggest Skye look at them on GitHub.

This step is done when Skye has the recommendation. Then stop: she types the command herself.
