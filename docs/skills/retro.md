# `/retro`

A look back over the current session for your corrections and steps that went wrong, which names a lasting fix for each one likely to happen again. It changes nothing: it ends with a `/draft-issue` line for you to type.

For the exact steps, see its [SKILL.md](../../skills/authoring/retro/SKILL.md).

## When to use it

- **Only you start it,** by typing `/retro` in the session you want looked at.
- Claude suggests it when you've corrected it on the same thing twice, because your global CLAUDE.md says to.
- It works in any project, with no `.claude/workflow.md` needed.

## What you'll see

1. **Which session it found.** Claude shows the session's first message and when it started, and waits for you to confirm it's this one.
2. **A reading in a subagent.** A trimmed copy of the session is read by a subagent, which lists each correction and each step that went wrong.
3. **A report.** For each finding that counts: what happened (with quotes), how often, the rule it broke if there is one, and the fix. One-offs are listed below, each with why it was dropped.
4. **A `/draft-issue` line per repo** holding the findings you kept, and which folder to type it in.

## Decisions it asks you about

- **Is this the right session?** If not, it stops rather than read another one.
- **Which findings to keep.** Only the kept ones go into the `/draft-issue` lines.

## Gotchas

- **Not every mistake counts.** A finding is kept when it happened twice in the session, or once here and once before (a memory note or an earlier issue), or when an instruction caused it. A slip with no cause in the instructions is a one-off.
- **Fixes are ranked on a ladder:** an automated check or test first, then a skill change, then a CLAUDE.md line. Each rung down relies more on Claude remembering. If a rule already existed and was broken anyway, the fix moves one rung up.
- **Skill fixes go to this repo.** A finding about a skill or the global CLAUDE.md belongs in the skills repo, even when you ran `/retro` in another project. The handover line says which folder to type it in.
- **If the trim fails or comes out empty,** it stops and shows the error: the transcript's format may have changed, and the filter needs updating first.

## Why it works this way

Each reason is in [looking back with /retro](../../decisions/2026-10-16-162552-retro.md):

- **Only you start it,** because the moment to look back is yours to choose.
- **It reads this session only,** found by the `/retro` you just typed, so a session running alongside isn't read by mistake.
- **A trimmed copy, read in a subagent** with no summary, so it reads what happened rather than what was remembered.
- **The ladder,** so CLAUDE.md files don't grow into a list of "please don't do X".
- **It hands over to `/draft-issue`** rather than creating issues, so the rules for writing issues stay in one place and duplicates are caught.
