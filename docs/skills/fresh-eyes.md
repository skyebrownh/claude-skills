# `fresh-eyes`

A review by readers who weren't in the conversation, so they see the work as it is rather than as it was meant to be. It only reports: it never edits, stages or commits a file.

For the exact steps, see its [SKILL.md](../../skills/guides/fresh-eyes/SKILL.md). The code smells its Standards reviewer looks for are in [smells.md](../../skills/guides/fresh-eyes/smells.md).

## When to use it

- `/handover` runs it on a branch before posting the handover.
- `/new-project` runs it on the new `SPEC.md`.
- You can ask for a review any time: of the current branch, or of a document by its path ("fresh-eyes on SPEC.md").

## What you'll see

It has two modes, picked by whether it's given a path:

- **Code mode** (no path) reviews everything the branch changes, committed or not. Two reviewers run side by side. **Standards** checks the change against the project's CLAUDE.md and a list of code smells. **Issue** checks it against the issue's acceptance criteria and approved plan.
- **Document mode** (a path, such as `SPEC.md`) gives the file to one cold reader, with nothing from the conversation. It looks for gaps, contradictions, unstated assumptions and requirements nobody could test.

Claude then checks each finding itself before keeping it, and reports them in three buckets:

- **Fix:** a real problem that would block the PR, each with a suggested fix.
- **Needs you:** a fair point that may not be worth fixing now, each with a recommendation.
- **Dropped:** findings Claude judged wrong, each with why, so you can overrule it.

An empty bucket says "None", so you can see it was checked. Then it stops, and says nothing has changed.

## Decisions it asks you about

Which findings to act on. It never decides that for you. When `/handover` runs it, though, the handover fixes the Fix findings that are inside the approved plan, each as its own commit, and passes the rest on to you.

## Gotchas

- **Code mode needs `.claude/workflow.md`,** to know the default branch to compare with. Without it, it stops and points to `/setup-project`. Document mode doesn't need it.
- **The Issue reviewer finds the issue from the branch name,** which starts with its number (`29-some-slug`). If it doesn't, Claude asks you which issue it is.
- **A short report is a good sign.** If reviewers find only nits, Claude says the work is fine rather than padding the report.

## Why it works this way

- **It only reports,** so deciding what to act on stays with you, and other skills can run it without asking first. See [a review skill that only reports](../../decisions/2026-10-15-190045-review-skill-only-reports.md).
- **The two reviewers run in parallel,** so neither colours the other's view; and the document reader gets nothing from the conversation, so it reads what the document actually says. Same file.
- **It's called `fresh-eyes`, not `review`,** to avoid a clash with Claude Code's built-in `/review`. Same file.
- **Fix, Needs you and Dropped,** each with a fix, a recommendation or a reason, so a report leads with what needs you. See [clearer review and handover reports](../../decisions/2026-10-16-194758-clearer-reports.md).
