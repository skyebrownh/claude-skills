---
name: writing-skills
description: Skye's style guide for writing Claude Code skills and CLAUDE.md files. Use when creating, editing, reviewing or splitting a skill (SKILL.md), or changing a CLAUDE.md.
---

# Writing skills (and CLAUDE.md)

Skye's rules for anything an agent reads: a skill, a CLAUDE.md, or a doc a skill points to. They come from building her first project's workflow, and from Matt Pocock's `writing-for-agents` (MIT; see DECISIONS.md in the skills repo). The goal is that the agent takes the **same process** every run.

For a new skill, start from [skill-template.md](skill-template.md).

## Where each piece belongs

| Kind of knowledge | Where it goes |
| --- | --- |
| How Skye works in every project (approve before committing, stage only reviewed files, never rewrite history) | A skill in her skills repo |
| Facts about one project (test command, deploy target, merge style) | That project's `.claude/workflow.md`, read by the skills; written by `/setup-project` |
| A project's own standards and architecture | That project's CLAUDE.md |
| What the app does and why | That project's spec |

A fact lives in **one** place. A copy of it elsewhere goes stale. When a skill needs a fact that the repo already shows (a `package.json` script, a config file), have the skill look it up rather than restate it. Write down only what can't be found by looking: the unwritten convention, the reason behind a choice.

## Who starts the skill

Decide this first. It sets the frontmatter.

- **Only Skye** (`disable-model-invocation: true`): any skill that commits, pushes, merges, publishes, deletes, or otherwise acts outside the conversation. **Typing the command is her approval**, so the skill opens by saying so ("Skye typed `/ship`. That is her approval to commit."). The description is a one-line summary for her and ends with "Use only when Skye types /name." It costs no context, but she has to remember it exists, so list it in the README.
- **Claude, too** (no flag): a guide or reference that Claude should reach for on its own, like this one. Its description is always loaded, so make every word count. Start with what it is, then list each **distinct** situation that should trigger it, one phrase each, with no synonyms for the same situation.
- A skill Claude can start may be called by other skills. A skill only Skye starts can't be, so material that two Skye-only skills share goes in a plain file they both point to.

## Shape of a skill that acts

These came out of `/ship` and `/merge` and are worth keeping in every skill that changes something:

- **Check first, act second.** Do every check before the first change, and **stop at the first problem**, saying what's wrong and what to do. Never fix problems silently.
- **Read the project's facts** from `.claude/workflow.md` in step 0. If a fact is missing, stop and point to `/setup-project`, rather than guessing a command.
- **Steps go on the task list,** and a skipped step stays there with its reason. That makes skipping visible.
- **Every step ends on a completion criterion:** a condition that tells you the step is done, ideally one you can check ("every section has an answer Skye has seen", not "understand the project"). A vague end invites rushing ahead to the next step.
- **Name the irreversible step.** Say plainly what can't be undone (merging deploys; a release publishes a tag) and what still needs a separate approval.
- **Hand back with what Skye needs next:** what happened, what's left, and what she must decide. Then stop.

## Writing the text

- **Say what to do,** not only what to avoid. "Stage exactly the reviewed files, by name" works better than "don't use `git add -A`", because naming the forbidden thing makes it more likely. Keep a prohibition only as a hard guardrail, and pair it with the positive version.
- **Give the reason** for any rule that isn't obvious, in a short clause. The agent then handles cases the rule didn't foresee, and Skye learns from reading it.
- **Use a compact word the model already knows** in place of a repeated explanation (e.g. "tracer bullet", "red" for a failing test). Repeat the word, not the sentence.
- **Cut sentences that change nothing.** If the model would do it anyway ("be careful", "be thorough"), delete the whole sentence.
- **Plain, friendly wording,** as if explaining to a colleague. No em-dashes in skill prose; use a comma, colon or full stop.

## Size and splitting

- Keep SKILL.md to what **every** run needs. Move material that only some runs need (a template, a long checklist, a per-tool variant) into a sibling file, linked from the step that needs it. That keeps the main steps easy to follow.
- Keep a concept's rule, reason and exceptions together under one heading, not scattered.
- Split a skill in two only when a different person or situation starts each half, or when later steps tempt the agent to rush an earlier one.
- When a skill changes, prune lines that no longer apply. Old layers that nobody dares delete are how skills rot.

## Before calling a skill done

- The frontmatter `name` matches the folder name, which is unique across buckets.
- The description says who starts it, and passes the "Who starts the skill" rules above.
- Every step has a completion criterion, and every stop condition says what to do next.
- Project facts are read from `workflow.md`, not written into the skill.
- The README lists it, and DECISIONS.md credits any idea taken from someone else's skill.
- If projects set up earlier need changing to match (a heading in `workflow.md`, a line in an issue template), a new migration in `setup-project/migrations.md` does it.
- `./install.sh <name>` links it, and you've tried it once in a real or throwaway project.
