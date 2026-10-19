# `/setup-project`

Interviews you and writes `.claude/workflow.md`: the facts about one project that the other skills read, such as the checks to run, the merge style and whether merging deploys.

For the exact steps, see its [SKILL.md](../../skills/workflow/setup-project/SKILL.md).

## When to use it

- **An existing project** you want to use these skills in. Run it once from the project's folder.
- **When a skill says the project is behind,** such as `/ship` or `/merge` stopping on an old process version. Running it again brings the project up to date.
- **When a fact changes,** such as a new test command or a new deploy target.
- You don't need to run it for a brand-new project: `/new-project` runs it for you. Claude may also start it, since it writes nothing without your approval.

## What `workflow.md` holds

The default branch, the checks before committing, what to set up before trying a change by hand, the PR template, the merge style, whether merging deploys, what to check after a deploy, when to suggest a release, and the project's **Process version**. The skills find each fact by its heading, so the headings stay as the [template](../../skills/workflow/setup-project/workflow-template.md) has them.

## What you'll see

1. It checks the folder is a git repo, and whether `workflow.md` already exists. If it does, this is an update, and it only asks about what's missing or changed.
2. For an update, it brings the project up to the current process version (see below).
3. It reads the project (README, CLAUDE.md, config files, recent merges and PRs) and guesses as many answers as it can.
4. It grills you on whatever it couldn't settle, and always asks whether merging deploys.
5. It shows the draft (the whole file when it's new, only what changes on an update), and writes it only once you approve.
6. It may offer a one-line pointer to `workflow.md` in the project's CLAUDE.md.

It commits nothing. `workflow.md` goes in with the project's next commit.

## Process versions and migrations

When this skills repo changes something that older projects also need (a renamed heading, a line in an issue template), it adds a numbered migration to [migrations.md](../../skills/workflow/setup-project/migrations.md). A project that's behind gets every migration above its version, in order, like database migrations. It shows them all together as before and after, applies them once you approve, and sets the new version last, so a run that stops partway still reads as behind.

## Gotchas

- **A migration's expected text doesn't match:** it stops and shows what it expected and what's there, then asks you what to do. A mismatch usually means you customised that file, so it won't overwrite it.
- **Some migrations need you to edit issues,** such as adding a `**Ships as:**` line to open parents. It tells you, but doesn't edit issues itself.
- **A section that doesn't apply** (nothing deploys, no releases) is removed rather than left as a placeholder.

## Why it works this way

- [Why project facts live in `workflow.md`](../../decisions/2026-10-15-130819-project-facts-in-workflow-md.md), in Markdown, and why skills stop rather than guess when a fact is missing.
- [Why projects have process versions](../../decisions/2026-10-15-181045-process-versions-and-migrations.md), why a mismatch stops, and why this skill applies migrations rather than a separate one.
- [Why Claude may start it](../../decisions/2026-10-16-135153-new-project.md), so `/new-project` can call it.
