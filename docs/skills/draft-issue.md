# `/draft-issue`

Turns one idea, or several, into draft GitHub issues from the project's own templates, and creates them only once you approve the drafts.

For the exact steps, see its [SKILL.md](../../skills/workflow/draft-issue/SKILL.md).

## When to use it

- Whenever you want to change something in a project, since every change starts from an issue.
- Only you start it. Typing `/draft-issue <ideas>` approves drafting, not creating.
- You can pass several ideas at once, such as a list of feedback, or the line `/new-project` hands you.
- It works before `/setup-project` has run: it finds the templates, labels and `SPEC.md` by looking.

## What you'll see

1. It numbers each idea and restates it in one line, so you can see how it understood you. Anything that isn't an idea is skipped, and it says what.
2. It reads the issue templates, `SPEC.md`, CLAUDE.md, the labels and milestones, the open parents, and the code each idea touches.
3. It searches open and closed issues for duplicates.
4. It grills you once for all the ideas, numbering the questions by idea (1.1, 2.1), so you can answer everything in one reply.
5. It shows every draft in one message, with a short summary, and stops.
6. Once you approve, it creates exactly what you approved, and gives you the links.

## Decisions it asks you about

- **Scope:** what's in and out. If an idea is on the spec's out-of-scope list, it quotes the line and asks whether to draft it anyway.
- **Size:** one issue, or a parent with children. One issue is one sitting, one branch, one PR. Bigger work becomes a parent whose children are vertical slices: thin pieces that each work end to end on their own.
- **Template, milestone and labels,** from the ones that exist.
- **Parent:** whether an idea belongs under an open parent.
- **Ships as,** for a new parent: `one PR` for all its children, or `one PR per child`. It recommends one, but never decides for you, because `/ship` relies on this line.
- **Combining ideas:** when two look related, it suggests combining them, and you decide.
- **Duplicates:** when an idea matches an open issue, it suggests a comment on that issue in place of a new one. When a closed issue's problem has come back, it suggests a new issue that links to the old one.

## Gotchas

- **Anything you don't mention counts as not approved.** It asks about it rather than assuming.
- **It never creates a label.** A new label changes the repo for every issue after it, so a missing one becomes a separate question.
- **If a create fails,** it stops and reports what was created so far, rather than retrying. A retry could create the same issue twice, and an issue is public as soon as it exists.
- **No issue templates in the project:** it stops and asks how issues should look, rather than guessing.
- **Blocked-by links** go only where one child really needs another first.

When it's done, it suggests planning the new issues with `/plan-issue`. If you asked it to "create and plan", it moves straight on to planning.

## Why it works this way

- [Why only you start it, why drafts are shown together, and why it never creates labels](../../decisions/2026-10-16-014310-drafting-issues.md).
- [How parents, children and Ships as work](../../decisions/2026-10-15-172511-parent-and-child-issues.md).
