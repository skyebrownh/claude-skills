# Skill template

Copy this into `skills/<bucket>/<name>/SKILL.md` and fill it in. Delete any part that doesn't apply. The `---` block at the top is the **frontmatter**: settings Claude Code reads before the skill runs.

```markdown
---
name: <name, same as the folder>
description: <What it does, in one line.> Use only when Skye types /<name>.
disable-model-invocation: true        # delete this line if Claude may start it on its own
argument-hint: "<what to type after the command, e.g. <PR#>>"
---

# <What the skill does, as a heading>

Skye typed `/<name> $ARGUMENTS`. **That is her approval to <action>.** <One sentence on what it must never do without a separate approval.>

Check everything first, and stop at the first problem, saying what's wrong and what to do. Put each step below on the task list.

## 0. Read the project's facts

Read `.claude/workflow.md`. You need: <sections>. If it's missing or still has `<placeholders>`, stop and say to run `/setup-project`.

## 1. Check before doing anything

Stop if:

- **<condition>:** <why it matters, and what to do instead>.

## 2. <First action>

<Steps.> This step is done when <checkable condition>.

## N. Hand back

Report briefly: <what happened>, <what's left>, <what Skye decides next>. Then stop.
```
