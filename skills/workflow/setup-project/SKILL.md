---
name: setup-project
description: Set up a project for Skye's personal skills by interviewing her and writing .claude/workflow.md, the project facts /ship and /merge read (checks, PR template, merge style, whether merging deploys). Also updates an existing one. Use only when Skye types /setup-project.
disable-model-invocation: true
argument-hint: "(no arguments; works on the current project)"
---

# Set up a project's workflow facts

Skye typed `/setup-project`. Your job is to write `.claude/workflow.md`: the facts about this project that her personal skills read, so that `/ship` and `/merge` work the same way everywhere. Its format is [workflow-template.md](workflow-template.md). Keep that template's headings exactly as they are, because the skills find facts by heading.

Put each step below on the task list, and keep a step there with a reason if you skip it. Write nothing until Skye approves the draft in step 4, and commit nothing at all.

## 1. Check where you are

Run `git rev-parse --show-toplevel` and `git status --short`.

- **Not a git repo:** stop and say so. These skills commit, push and open PRs, so they need git.
- **`.claude/workflow.md` already exists:** read it, and treat this run as an **update**. Ask only about sections that are missing, still hold `<placeholders>`, or that Skye says have changed.

This step is done when you know the repo root and whether this is a new file or an update.

## 2. Read the project before asking anything

Work out as many answers as you can yourself, so that Skye only has to confirm them. Look at:

- the default branch: `gh repo view --json defaultBranchRef`, or `git symbolic-ref refs/remotes/origin/HEAD`;
- how tests and checks run: CLAUDE.md, README, `pyproject.toml`, `package.json`, a `Makefile`, and CI files in `.github/workflows/`;
- the PR template: `.github/pull_request_template.md` (or `.github/PULL_REQUEST_TEMPLATE/`), and whether recent PRs carry milestones and labels: `gh pr list --state merged --limit 5 --json title,milestone,labels`;
- the merge style: how recent merges look on the default branch (`git log --oneline -15`). A `(#N)` suffix with one commit per PR means squash;
- deploys: `railway.json`, `vercel.json`, `fly.toml`, `netlify.toml`, a `Procfile`, deploy workflows, and anything CLAUDE.md says about deploying;
- after-deploy checks and releases: CLAUDE.md, and `gh release list --limit 3`.

This step is done when every section of the template has either a guessed answer with its source, or is marked "don't know".

## 3. Interview Skye in rounds

Ask in rounds of at most four numbered questions, one per section that still needs a decision. Give each question your **recommended answer** and where it came from, and word it so that "yes" accepts the recommendation, for example: "1. Tests: `uv run python manage.py test` (from README). Use that?" Skye can reply "all yes", or with a number and a correction.

- Don't ask about anything you found for certain in step 2 (e.g. a PR template that exists). Put it in the draft and let her correct it there.
- **Ask about deploying explicitly, even if you're confident.** "Merging deploys" is the fact `/merge` relies on to warn her, so it must come from her.
- Ask follow-up rounds until every section is settled. If a section doesn't apply (no releases, nothing deploys), it gets removed rather than left with a placeholder.

This step is done when every section has an answer Skye has seen.

## 4. Show the draft, then write it

Show the complete file, filled in from [workflow-template.md](workflow-template.md), with no `<placeholders>` left. For an update, show only what changes. Write `.claude/workflow.md` only after Skye approves the draft.

## 5. Offer a pointer from CLAUDE.md

If the project has a CLAUDE.md that doesn't mention `workflow.md`, offer to add one line where it describes the workflow, for example:

> Project facts for Skye's personal skills (`/ship`, `/merge`) are in `.claude/workflow.md`; update it with `/setup-project`.

Show the exact change and add it only on her OK. If CLAUDE.md states the same facts elsewhere (e.g. a test command), point out the duplication; don't remove it yourself.

## 6. Hand back

Say what was written. List both files as links if CLAUDE.md changed. Say that nothing is committed: `workflow.md` gets committed with the project's next reviewed change, like any other file. Then say which skills can now be used here: `/ship` and `/merge`, if they're installed.
