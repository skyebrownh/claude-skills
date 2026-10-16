---
name: handover
description: Hand the committed work on an issue's branch over for Skye's review. Runs the project's checks and a fresh-eyes review, then posts a `## Handover` comment on the issue that records the exact commit it covers. Use when a build is finished, after a round of revisions has been committed, or when Skye asks for a handover.
argument-hint: "(no arguments; hands over the current branch)"
---

# Hand over an issue's branch

The work on this branch is built and committed. Your job is to check it, then hand it to Skye for review in a fixed format, posted on the issue as well as shown here. The comment records the commit it covers, so `/ship` can tell, from any session, whether the review is still current.

Check everything first, and stop at the first problem, saying what's wrong and what to do. Put each step below on the task list.

**When `/build` names a worktree** (a parallel build), run every command below in that worktree, not in Skye's folder, so her folder never switches branch under her.

## 0. Read the project's facts

Read `.claude/workflow.md` at the repo root. You need **Default branch**, **Checks before committing** and **Manual test setup**.

- **It's missing, or Default branch or Checks still holds a `<placeholder>`:** stop and say to run `/setup-project` first. Don't guess the commands.
- **The project is on an older version of the process:** its version is the number under **Process version** (1 if that section is missing), and the current version is the newest heading in [setup-project's migrations.md](../setup-project/migrations.md). If the project's is lower, stop. Name each migration it's missing and say to run `/setup-project`.
- **Manual test setup is missing:** carry on without it, and say in the hand-back that the section is missing and `/setup-project` adds it.

This step is done when you know the default branch, the checks, and the manual setup (or that there's none).

## 1. Check before doing anything

First work out the **base**, the branch this work is compared with. It's the default branch, except for a child of a "one PR" parent built on its own branch: then it's the parent's branch, so the comparison leaves out siblings already committed there. Find the parent and its **Ships as** line as `/build` does (`gh api repos/{owner}/{repo}/issues/<N>/parent --jq .number`, a 404 meaning none), and its branch with `git branch --list '<P>-*'`. If this branch *is* the parent's branch, the base is the default branch. Stop and ask Skye if the parent's **Ships as** line is missing or isn't `one PR` or `one PR per child`, or if `<P>-*` matches no branch or more than one: the base would be a guess.

Then run `git branch --show-current` and `git status --porcelain`. Stop if:

- **The branch is the default branch.** Work is handed over from an issue's branch. Ask Skye which branch to hand over.
- **The branch name doesn't start with an issue number** (`<N>-<slug>`). Ask Skye which issue the work is for.
- **The issue isn't open:** `gh issue view <N> --json title,state,body,comments`. Say so, and ask whether the branch is for a different issue.
- **Anything is uncommitted or untracked** (`git status --porcelain` prints anything). A handover covers committed work only, because the commit it records is what Skye reviews and `/ship` pushes. Commit the work, or ask Skye about a stray file, then run `/handover` again.
- **The branch has no commits of its own:** `git log --oneline <base>..HEAD` prints nothing. There's nothing to hand over.

This step is done when every check passes, and you know the base and have the issue's body and comments.

## 2. Run the checks

Run every command under **Checks before committing**, in order, on the branch tip. Note each result and the test count.

**A command fails or reports a problem:** stop and report it. Fix it within the plan, commit, and run `/handover` again. Post nothing until the checks pass: a handover says the work is ready.

This step is done when every check passes.

## 3. Review it with fresh eyes

Follow `fresh-eyes` in code mode, naming the base (and the worktree, if there is one). Then:

- **Act on** findings within the approved plan: fix each one as its own commit, with a short plain message and the co-author line that this conversation's attribution instructions give. A separate commit lets Skye see each fix, and revert it on its own. Then re-run the checks from step 2.
- **Act on** findings outside the plan (they need new behaviour): don't fix them. List them, and suggest a new issue.
- **Consider, Noted and Dropped:** change nothing, and list them in the handover so Skye can overrule your judgement.

This step is done when every Act on finding is either fixed, with its commit's short sha, or listed with the reason it wasn't fixed, and the checks pass on the new tip.

## 4. Write the handover

Run `git rev-parse HEAD` for the commit it covers: the branch tip, after any fixes. Fill in this format:

````markdown
## Handover

**Branch:** `<branch>` · **Covers:** `<short sha>` (`<full sha>`), the branch tip · **Compared with:** `<base>`

<Only on a re-run: "Replaces the handover for `<its short sha>`." and one line on what the revisions changed.>

### Review it

```sh
git switch <branch>
git diff <base>...<branch>          # every change since the branch left <base>
git log --oneline <base>..<branch>  # its commits
```

### What changed

<One sentence on what the work does.>

- `<path>`: <short note>

### Test results

- `<command>`: <passed, with the count>
- Tests the plan didn't foresee: <each one and the behaviour it covers, or "None">

### Fresh-eyes review

- **Fixed:** <finding> (`<short sha>`), or "None"
- **Not fixed:** <Act on findings outside the plan, with a suggested issue>, or "None"
- **Consider:** …
- **Noted:** …
- **Dropped:** <finding>: <why>

### Manual test steps

1. <What Manual test setup says to do before the steps.>
2. <What to do.> You should see <what>.
3. <What Manual test setup says to undo afterwards, if anything.>
````

- **Files are plain paths in the comment,** because the branch stays local until `/ship`, so a link to it on GitHub would be broken. In chat, write them as links, so Skye can click them.
- **Manual test steps** cover what the plan says the work does, including its stop conditions and error paths, each with what Skye should see.
- **No Manual test setup in `workflow.md`:** start the steps from what the project's README says about running it, and add a line under the steps saying the section is missing.

This step is done when every section is filled in, with no `<placeholders>` left.

## 5. Post it, then hand back

Show the handover in chat. Then post it on the issue, without asking first: it's a record of what was handed over, and Skye reviews it after it's posted.

```sh
gh issue comment <N> --body-file <file in the scratchpad>
```

The latest `## Handover` comment is the one that counts, so after each round of revisions, run `/handover` again rather than editing an old comment.

This step is done when the comment is posted and you have its link.

Hand back with the comment's link, and anything step 0 found missing. Then stop: Skye reviews the branch, asks for revisions, or runs `/ship`.
