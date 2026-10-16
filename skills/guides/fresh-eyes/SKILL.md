---
name: fresh-eyes
description: A review by readers with fresh context, which only reports and never changes a file. Use to review the current branch's work before a handover, to review a spec or other document by its path, or when Skye asks for a review.
argument-hint: "[path to a document, e.g. SPEC.md]"
---

# Fresh eyes on the work, or a document

Reviewers with fresh context read the work and report what they find. You judge their findings and hand Skye a sorted report. **This skill only reads.** It never edits, stages or commits a file, and neither do its subagents: what to act on is Skye's decision, made after she has seen the report.

Put each step below on the task list.

## 0. Pick the mode

- **Document mode:** you were given a path (such as `SPEC.md`). Check the file exists; if it doesn't, stop and ask for the right path. Go to step 5. Document mode doesn't read `.claude/workflow.md`, because it compares nothing with a branch, so it also works in a project that `/setup-project` hasn't set up yet (as `/new-project` needs, when it checks a spec).
- **Code mode,** the default: no path was given. Review the current branch. Carry on with step 1.

This step is done when you know the mode and, for a document, its file exists.

## 1. Read the project's facts (code mode)

Read `.claude/workflow.md` at the repo root. You need **Default branch**. If the file is missing, or that section still holds a `<placeholder>`, stop and say to run `/setup-project` first, rather than guessing the branch.

**Another skill names a base branch or a folder** (as `handover` does for a child built on its own branch, or for a worktree): compare with that base instead of the default branch, and run every command in that folder.

This step is done when you know the default branch's name, and any base or folder you were given.

## 2. Gather the diff (code mode)

The diff covers committed, uncommitted and untracked work alike, so the review sees everything the branch changes, whether or not it's committed yet:

```sh
base=$(git merge-base <base branch, or the default branch> HEAD)
git diff "$base"                                # tracked files: the working tree against where the branch began
git status --short --untracked-files=all        # lines starting ?? are new, untracked files
```

Read each untracked file in full: it's new, so all of it is part of the change.

**Both are empty:** stop and say there's nothing to review.

This step is done when you have the diff and the full text of every untracked file.

## 3. Gather what each reviewer needs (code mode)

- **For Standards:** the project's CLAUDE.md, and the whole of [smells.md](smells.md). Subagents can't open this skill's files, so their text goes into the prompt itself.
- **For Issue:** the issue number is the start of the branch name (`<N>-<slug>`, from `git branch --show-current`). If the branch name doesn't start with a number, ask Skye which issue the work is for, rather than guessing. Then run `gh issue view <N> --json title,body,comments` and take:
  - the acceptance criteria from the body;
  - the comment headed `## Plan (approved)` (the latest, if there are several);
  - any requirement IDs the issue cites, each with its text from `SPEC.md` if the project has one.

This step is done when you have each item above, or know it doesn't exist (no CLAUDE.md, no approved plan, no SPEC.md). Say which are missing in the report.

## 4. Run both reviewers at once (code mode)

Start two subagents with `subagent_type: Explore`, **both in one message** so they run in parallel and neither sees the other's view. Explore agents can read and search but can't edit, which keeps the review read-only.

Give each the diff and the untracked files' text. If the diff is too long to paste, give the commands from step 2 instead (with the folder to run them in, if you were given one), and tell the reviewer to read their output in full. Then add:

**Standards** gets the project's CLAUDE.md and smells.md, and this brief:

> Review this change against the project's CLAUDE.md and the code smells listed. Report (a) each place the change breaks a CLAUDE.md rule, quoting the rule, and (b) each smell you spot, named as "possible <smell>". A CLAUDE.md breach can be a hard finding; a smell is always a judgement call. Where CLAUDE.md allows something a smell would flag, leave the smell out. Skip anything a linter or formatter already enforces. Give `file:line` for every finding. Read only: change no files. Under 400 words.

**Issue** gets the issue's acceptance criteria, its approved plan and the requirements it cites, and this brief:

> Review this change against what the issue asked for. Report (a) each criterion, plan step or requirement that is missing or only partly done; (b) anything that looks done but wrong; (c) anything in the change that nobody asked for. Quote the criterion, plan line or requirement for each finding, and give `file:line` where there is one. Read only: change no files. Under 400 words.

This step is done when both reports are back. Go to step 6.

## 5. Run the cold reader (document mode)

Start one subagent with `subagent_type: Explore`. Give it **only** the document's path and the brief below: no summary of this conversation and no hint of what the document is meant to say. A reader who wasn't in the conversation sees what the document actually says, which is what a later reader (or a later Claude) will see too.

> Read <path> in full, and any file it names that you need to follow it. You know nothing else about this project. Report (a) gaps: questions a builder would have to ask before starting; (b) contradictions between two parts; (c) assumptions the document relies on but never states; (d) requirements that can't be tested, because nothing says how to tell they're met. Give a section heading or `file:line` and a short quote for each finding. Read only: change no files. Under 400 words.

This step is done when the report is back.

## 6. Judge the findings

You are the lead reviewer, not a messenger: reviewers working from a diff or a single document miss context that you have. Check each finding against the code or the document before keeping it.

- **Trace it.** "What if this is empty?" is a finding only if something can actually pass an empty value.
- **A preference isn't a problem.** "I would have done it differently" is kept only with a concrete problem the current approach causes.
- **Check the context.** A finding about code the change didn't touch, or about a pattern the rest of the project uses on purpose, is a reviewer missing context.
- **All nits means the work is fine.** Reviewers fill their reports; when nothing serious turns up, say so.

Sort every finding you keep into one bucket, each with `file:line` or a section reference, which reviewer raised it, and a one-line reason:

- **Act on:** a real problem with correctness, a breach of CLAUDE.md, or a missing or wrong criterion. It would block the PR.
- **Consider:** a fair point, but it may not be worth fixing now. Say the trade-off.
- **Noted:** true, but nothing to do at this stage.

Drop findings you judge wrong, with a one-line note each on why, so Skye can overrule you.

This step is done when every finding is either in a bucket or in the dropped list.

## 7. Hand back

Report in this shape:

```markdown
## Review of <branch, or document path>

<Mode, the reviewers that ran, and anything missing (no CLAUDE.md, no approved plan, no SPEC.md).>

### Act on
- `<file:line or section>`: <finding> (<reviewer>). <Reason.>

### Consider
- …

### Noted
- …

### Dropped
- <finding> (<reviewer>): <why it's wrong>.
```

Write "None" under an empty bucket, so Skye can see it was checked. Then say plainly that **nothing has changed**: no file was edited, staged or committed. Which findings to act on is Skye's decision, so stop and wait for her.
