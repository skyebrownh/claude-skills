# `writing-skills`

The style guide for anything an agent reads: a skill's SKILL.md, a CLAUDE.md, or a doc a skill points to. Its goal is that Claude follows the same process every time a skill runs.

For the rules themselves, see its [SKILL.md](../../skills/authoring/writing-skills/SKILL.md). A new skill starts from [skill-template.md](../../skills/authoring/writing-skills/skill-template.md).

## When to use it

- Claude follows it whenever it creates, edits, reviews or splits a skill, or changes a CLAUDE.md.
- This repo's CLAUDE.md asks for it on every SKILL.md and on that CLAUDE.md itself.
- You can ask for it by name to review a skill you've written.

## What it covers

- **Where each piece of knowledge belongs:** how you work everywhere goes in a skill; one project's facts go in its `.claude/workflow.md`; its standards in its CLAUDE.md; what the app does in its spec.
- **Who starts a skill:** only you, or Claude too. This is decided first, because it sets the skill's frontmatter and how its description is written.
- **The shape of a skill that changes things:** check everything first, then act; steps on the task list; a clear "done when" on each step; the irreversible step named.
- **How to write the text,** and **when to split** a skill or move material into a sibling file.
- **A done-checklist** for calling a skill finished.

## Gotchas

- **One fact, one place.** If a fact can be found by looking (a script in `package.json`, a config file), the skill looks it up rather than copying it.
- **Anything hard to undo is yours to start.** A skill that pushes, merges, publishes or deletes gets `disable-model-invocation: true`, and opens by saying that typing the command is your approval. Committing on a feature branch or posting a record doesn't count.
- **The done-checklist reaches beyond the skill:** the README, the guide's line, the skill's page in `docs/skills/`, a `decisions/` file for borrowed ideas, and a migration if projects set up earlier need changing.

## Why it works this way

The reasons are in its SKILL.md, next to each rule:

- **One fact, one place,** because a copy elsewhere goes stale.
- **Typing the command is the approval,** so a skill only you start never acts without you, and a skill Claude can start is one that's safe for it to reach for.
- **Every step ends on a completion criterion,** because a vague end invites rushing on to the next step.
- **Say what to do, not only what to avoid,** because naming the forbidden thing makes it more likely.
- **Give the reason for a rule,** so Claude can handle cases the rule didn't foresee, and you learn from reading it.
- **Keep SKILL.md to what every run needs,** so the main steps stay easy to follow; and prune lines that no longer apply, because old layers nobody dares delete are how skills rot.

Its writing rules come partly from Matt Pocock's skills, credited in [start a personal skills repo](../../decisions/2026-10-15-130818-start-a-personal-skills-repo.md).
