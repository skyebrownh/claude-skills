---
name: ship
description: Commit the reviewed work on an issue's branch, push it, and open its pull request. Handles single issues, children that ship alone, and parents whose children share one PR. Running /ship is Skye's approval to commit. Reads the project's checks and PR conventions from .claude/workflow.md. Use only when Skye types /ship.
disable-model-invocation: true
argument-hint: "[child#] (only on a parent's branch)"
---

# Ship an issue's branch

Skye typed `/ship`. **That is her approval to commit** the work on the current branch, which she has reviewed in her editor. After committing, push the branch and open its pull request. **Never merge.** Merging can deploy, and it needs `/merge` or her OK in chat.

The approval arrives as a typed command, possibly in a new session, so **check everything first**. Stop at the first problem, say what's wrong and what to do, and don't fix problems silently. Put each step below on the task list.

## 0. Read the project's facts

Read `.claude/workflow.md` at the repo root. You need these sections: **Default branch**, **Checks before committing**, **Pull requests** and **Merging**.

- **It's missing, or a section you need still holds `<placeholders>`:** stop and say to run `/setup-project` first. Don't guess the commands.
- If the project's CLAUDE.md disagrees with `workflow.md`, stop and ask which is right.

## 1. Check before doing anything

Run `git status` and `git branch --show-current`. Stop if:

- **The branch is the default branch.** Work never gets committed there.
- **The branch name doesn't start with an issue number** (`<N>-<slug>`, e.g. `12-closed-month-admin`). Every branch is named for one issue, or for a parent issue.
- **The issue isn't open:** `gh issue view <N> --json title,state,milestone,labels,body,comments`.

### Work out what kind of branch this is

```sh
gh api repos/{owner}/{repo}/issues/<N> --jq .sub_issues_summary.total   # above 0: #N is a parent
gh api repos/{owner}/{repo}/issues/<N>/parent --jq .number              # a 404 means #N has no parent
```

A parent's **Ships as** is the line in its body starting `**Ships as:**`. Remove any `<!-- … -->` comment from it. What's left must be `one PR` or `one PR per child` (any case). **If it's anything else, or the line is missing, stop** and ask Skye to set it on the parent: how the children become PRs is her decision, so never guess it.

| #N is | Ships as | What to do |
| --- | --- | --- |
| a parent | one PR | Follow [parent-pr.md](parent-pr.md) instead of the rest of this file. |
| a parent | one PR per child | Stop. Each child ships from its own branch (`<child#>-<slug>`). |
| a child of #P | one PR per child (#P's) | Carry on below. The PR also says `Part of #P`. |
| a child of #P | one PR (#P's) | Stop. Its work is committed on #P's branch, with `/ship <N>` there. |
| neither | | Carry on below, as a single issue. |

**A child number was given, but this isn't a parent's branch:** stop. `/ship <child#>` only works on a parent's branch.

### Check the work itself

Stop if:

- **There's nothing to commit.** There may be nothing left to ship.
- **The issue is blocked by an open issue.** List them with `gh api repos/{owner}/{repo}/issues/<N>/dependencies/blocked_by --jq '.[] | select(.state == "open") | "#\(.number) \(.title)"'`. Name each one, because the blocked-by link says this work depends on it landing first.
- **This conversation has no handover for issue #N:** what changed, test results, manual test steps, and a suggested commit message. Without one, there's no sign Skye reviewed the work, so don't commit. Offer to give the handover first, then wait for her to review it and run `/ship` again. (For now the handover lives in the conversation. `/handover`, #8, will move it to a comment on the issue.)

## 2. Stage only the reviewed files

Compare `git status --short` with the files in the handover's "What changed".

- Stage exactly those files, by name: `git add <file> …`. That way only reviewed files can enter the commit, even if something else changed in the folder.
- **Anything else changed or untracked** (a stray file, a scratch file, something the handover doesn't list): stop and ask whether it belongs in this commit.
- **A handover file changed again since the handover:** say so, and ask whether Skye has reviewed the newer version.

## 3. Re-run the checks

Run every command under **Checks before committing**, in order. Note the test count for the PR. If any command fails or reports a problem, **stop** and report it, without committing.

## 4. Commit

The message is the issue's title, exactly, then a blank line, then the co-author line that this conversation's attribution instructions give:

```sh
git commit -F - <<'EOF'
<issue title>

Co-Authored-By: <the co-author line>
EOF
```

Then run `git log --oneline -1` and `git status --short`, to show the commit and confirm nothing reviewed was left behind.

## 5. Push

```sh
git push -u origin <branch>
```

## 6. Open the pull request

Write the description to a file in the scratchpad directory. Passing it with `--body-file` keeps quotes and backticks intact. Follow the template named under **Pull requests**. If the template is "none", use these same parts as headings:

- `Closes #N` on the first line, so merging closes the issue. For a child, `Part of #P` on the next line, so the PR links back to the parent.
- **What changed:** one plain-language sentence on what the PR does and why, then each file with a short note, taken from the handover.
- **Differences from the approved plan,** if the issue has a plan comment and the build differs from it, said plainly.
- **Acceptance criteria:** the issue's checklist copied **word for word**, ticked where done, with the test count on the tests line (e.g. "(238 tests, 3 new)"). Leave anything not done unticked, with a short italic reason.
- **How to test:** the handover's numbered steps.
- **Checklist,** if the template has one: tick what applies, and for anything else leave it unticked with a reason.
- Keep any closing lines the template has, then the PR attribution line from this conversation's instructions.

```sh
gh pr create --title "<issue title>" --body-file <file> --base <default branch>
```

If **Pull requests** says to copy the milestone and labels, add `--milestone "<issue's milestone>"` and a `--label <label>` for each of the issue's labels.

## 7. Check it and hand back

```sh
gh pr view <PR> --json number,url,mergeable,mergeStateStatus
```

`mergeable` can read `UNKNOWN` for a few seconds after a PR is created. Check again shortly rather than reporting it as a problem.

Report briefly:

- the commit (short ID and title) and the branch pushed;
- the PR link, its milestone and labels, and whether GitHub says it can merge;
- any criterion left unticked, and why;
- what merging will do, from **Merging**. If merging deploys, say so plainly, even when the PR doesn't change the running app. Skye approves with `/merge <PR#>` or by saying so in chat.

Then stop. Don't merge.
