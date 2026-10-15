---
name: ship
description: Commit the reviewed work on a single-issue branch, push it, and open its pull request. Running /ship is Skye's approval to commit. Reads the project's checks and PR conventions from .claude/workflow.md. Use only when Skye types /ship.
disable-model-invocation: true
argument-hint: "(no arguments; works on the current branch)"
---

# Ship a single-issue branch

Skye typed `/ship`. **That is her approval to commit** the work on the current branch, which she has reviewed in her editor. After committing, push the branch and open its pull request. **Never merge.** Merging can deploy, and it needs `/merge` or her OK in chat.

The approval arrives as a typed command, possibly in a new session, so **check everything first**. Stop at the first problem, say what's wrong and what to do, and don't fix problems silently. Put each step below on the task list.

## 0. Read the project's facts

Read `.claude/workflow.md` at the repo root. You need these sections: **Default branch**, **Checks before committing**, **Pull requests** and **Merging**.

- **It's missing, or a section you need still holds `<placeholders>`:** stop and say to run `/setup-project` first. Don't guess the commands.
- If the project's CLAUDE.md disagrees with `workflow.md`, stop and ask which is right.

## 1. Check before doing anything

Run `git status` and `git branch --show-current`. Stop if:

- **The branch is the default branch.** Work never gets committed there.
- **There's nothing to commit.** There may be nothing left to ship.
- **The branch name doesn't start with an issue number** (`<N>-<slug>`, e.g. `12-closed-month-admin`). It may be a branch for several issues, which this version of `/ship` doesn't handle. If the project has its own `/ship-set`, suggest that.
- **The issue isn't open:** `gh issue view <N> --json title,state,milestone,labels,body,comments`.
- **This conversation has no handover for issue #N:** what changed, test results, manual test steps, and a suggested commit message. Without one, there's no sign Skye reviewed the work, so don't commit. Offer to give the handover first, then wait for her to review it and run `/ship` again.

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

- `Closes #N` on the first line, so merging closes the issue.
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
