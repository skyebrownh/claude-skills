---
name: setup-project
description: Set up a project for Skye's personal skills by interviewing her and writing .claude/workflow.md, the project facts /handover, /ship and /merge read (checks, PR template, merge style, whether merging deploys). Also updates an existing one, and brings a project set up for an older version of the process up to date. Use only when Skye types /setup-project.
disable-model-invocation: true
argument-hint: "(no arguments; works on the current project)"
---

# Set up a project's workflow facts

Skye typed `/setup-project`. Your job is to write `.claude/workflow.md`: the facts about this project that her personal skills read, so that `/handover`, `/ship` and `/merge` work the same way everywhere. Its format is [workflow-template.md](workflow-template.md). Keep that template's headings exactly as they are, because the skills find facts by heading.

Put each step below on the task list, and keep a step there with a reason if you skip it. Write nothing until Skye approves (the migrations in step 2, the draft in step 5), and commit nothing at all.

## 1. Check where you are

Run `git rev-parse --show-toplevel` and `git status --short`.

- **Not a git repo:** stop and say so. These skills commit, push and open PRs, so they need git.
- **`.claude/workflow.md` already exists:** read it, and treat this run as an **update**. Ask only about sections that are missing, still hold `<placeholders>`, or that Skye says have changed.

Then read [migrations.md](migrations.md). The current version is its newest heading. For an update, also note the project's version: the number under **Process version**, or 1 if that section is missing.

This step is done when you know the repo root, whether this is a new file or an update, and (for an update) the project's version and the current one.

## 2. Bring the project up to date

Skip this step for a new file, which gets the current version in step 5.

- **The project is on the current version:** say "nothing to do" for migrations, and go on to step 3.
- **It's behind:** it needs every migration in [migrations.md](migrations.md) above its version, in order. Follow that file's "How to apply a migration":
  1. Check each change's expected text in the project. If any doesn't match, stop and show Skye what you expected and what's there, and ask what to do. Don't overwrite it.
  2. Show every pending change together, as one set: each file, and the before and after of each change. Name the migrations it covers (e.g. "2: Parent PRs").
  3. Apply them only after Skye approves, then set **Process version** to the current version.
  4. Pass on anything a migration says to tell her (such as open issues that need editing).

This step is done when the project's **Process version** is the current version, or Skye has decided what to do about a change that didn't match.

## 3. Read the project before asking anything

Work out as many answers as you can yourself, so that Skye only has to confirm them. For an update, look only at what the sections you're asking about need. Look at:

- the default branch: `gh repo view --json defaultBranchRef`, or `git symbolic-ref refs/remotes/origin/HEAD`;
- how tests and checks run: CLAUDE.md, README, `pyproject.toml`, `package.json`, a `Makefile`, and CI files in `.github/workflows/`;
- what to do before trying a change by hand: the README's run instructions, `.claude/launch.json`, `docker-compose.yml`, a `Procfile`;
- the PR template: `.github/pull_request_template.md` (or `.github/PULL_REQUEST_TEMPLATE/`), and whether recent PRs carry milestones and labels: `gh pr list --state merged --limit 5 --json title,milestone,labels`;
- the merge style: how recent merges look on the default branch (`git log --oneline -15`). A `(#N)` suffix with one commit per PR means squash;
- deploys: `railway.json`, `vercel.json`, `fly.toml`, `netlify.toml`, a `Procfile`, deploy workflows, and anything CLAUDE.md says about deploying;
- after-deploy checks and releases: CLAUDE.md, and `gh release list --limit 3`.

This step is done when every section of the template has either a guessed answer with its source, or is marked "don't know".

## 4. Interview Skye in rounds

Follow `grilling`, with one question per section that still needs a decision. Three things are specific to this skill:

- Don't ask about anything you found for certain in step 3 (e.g. a PR template that exists). Put it in the draft and let her correct it there.
- **Ask about deploying explicitly, even if you're confident.** "Merging deploys" is the fact `/merge` relies on to warn her, so it must come from her.
- **A section that doesn't apply** (no releases, nothing deploys) gets removed rather than left with a placeholder.

This step is done when every section has an answer Skye has seen.

## 5. Show the draft, then write it

Show the complete file, filled in from [workflow-template.md](workflow-template.md), with no `<placeholders>` left. Its **Process version** is the current version from [migrations.md](migrations.md). For an update, show only what changes, and skip this step if nothing does. Write `.claude/workflow.md` only after Skye approves the draft.

## 6. Offer a pointer from CLAUDE.md

If the project has a CLAUDE.md that doesn't mention `workflow.md`, offer to add one line where it describes the workflow, for example:

> Project facts for Skye's personal skills (`/handover`, `/ship`, `/merge`) are in `.claude/workflow.md`; update it with `/setup-project`.

Show the exact change and add it only on her OK. If CLAUDE.md states the same facts elsewhere (e.g. a test command), point out the duplication; don't remove it yourself.

## 7. Hand back

Say what was written, including which migrations were applied and the project's version now. List every changed file as a link. Say that nothing is committed: `workflow.md` gets committed with the project's next change, like any other file. Then say which skills can now be used here: `/handover`, `/ship` and `/merge`, if they're installed.
