# `/new-project`

Turns an idea into a brand-new project: a spec, CLAUDE.md, README, GitHub repo, `workflow.md` and a first commit, one approved phase at a time.

For the exact steps, see its [SKILL.md](../../skills/workflow/new-project/SKILL.md).

## When to use it

- You have an idea and an empty folder for it, such as `~/Developer/<name>`. Open Claude Code in that folder and type `/new-project <the idea>`.
- Only you start it. Typing the command approves starting, not creating the repo or pushing.
- For a project that already exists, use `/setup-project` instead.

## What you'll see

1. It checks that `gh` is logged in and that the folder isn't inside another repo, and works out which phases are already done.
2. It says the idea back in its own words, for you to correct.
3. It grills you on the problem, users, scope, flows, stack and timeline.
4. It sets two real options side by side for each big choice (stack, hosting) and recommends one.
5. It shows `SPEC.md`, then has a fresh reader challenge it, and you pick which findings to fix.
6. It shows `CLAUDE.md` and `README.md`, then the git and GitHub setup: repo, `.github/` templates, labels and milestones.
7. It runs `/setup-project` to write `.claude/workflow.md`, then makes the first commit and pushes it.
8. It ends with a `/draft-issue` line for your first issues, in build order, for you to type.

Every phase stops and waits for your approval. Nothing is written, created on GitHub or pushed before you approve that phase.

## Decisions it asks you about

- **The spec:** what's in v1, what's later, and what's a non-goal. These feed the first issues.
- **The big choices:** which option to pick for anything costly to change later.
- **The spec review:** which of the fresh reader's findings to fix.

## Gotchas

- **It stops inside another repo,** because a new repo there would be nested in the old one. Make the folder somewhere else and start again there.
- **A session can end between phases.** Start a fresh one in the same folder: it sees which files exist and offers to carry on. Once `SPEC.md` is written is a good moment for that.
- **Creating the repo can't be quietly undone.** Deleting it later needs a `gh` permission you grant yourself, or the repo's Settings page.
- **If a GitHub command fails,** it stops and reports what was made, rather than retrying and making something twice.
- **The first commit goes straight to `main`.** An empty repo has no branch to start from. Every later change goes through an issue's branch.
- **A choice that needs a prototype** isn't built here. It becomes an issue to plan later.

## Why it works this way

- [Why it ends with a `/draft-issue` line instead of drafting the issues itself](../../decisions/2026-10-16-135153-new-project.md), along with why the spec is the handoff point, why one commit goes to `main`, and where its ideas were borrowed from.
- [Why project facts go in `workflow.md`](../../decisions/2026-10-15-130819-project-facts-in-workflow-md.md), which it writes through `/setup-project`.
