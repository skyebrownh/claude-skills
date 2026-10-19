# `/plan-issue`

Turns an issue into a plan you approve, then posts it on the issue as `## Plan (approved)`, where `/build` reads it.

For the exact steps, see its [SKILL.md](../../skills/workflow/plan-issue/SKILL.md).

## When to use it

- After an issue is created, before building it. Type `/plan-issue <N>`, or several numbers to plan a few at once.
- Claude may also start it, for example when you ask `/draft-issue` to "create and plan". It only reads until you approve, so starting it needs no approval of its own.
- It works without `workflow.md`. The plan then says the checks will come from `/setup-project`.

## What you'll see

1. It checks each issue is open and not a parent, and names any open issue blocking it.
2. It reads the issue, its parent, the spec, CLAUDE.md and the code the work affects.
3. For work with more than one reasonable way to do it, it sketches two approaches with their trade-offs and recommends one. Simple work gets one line on why one approach is enough.
4. It writes the whole plan out in the chat, then asks about what's still open. After each round of answers, it writes the updated plan out in full again.
5. Once you approve, it posts the plan on the issue, then suggests `/build <N>`.

The plan's sections are set out in step 5 of its [SKILL.md](../../skills/workflow/plan-issue/SKILL.md): mainly the decisions made, the files that change and why, and how it will be tested.

### Draft and approved plans

While you review it in the chat, the plan is headed `## Plan (draft)`. It becomes `## Plan (approved)` only when it's posted, because `/build` treats that heading as your approval. If an issue already has an approved plan, it asks whether to replan it. The latest plan comment is the one that counts.

## Decisions it asks you about

- **The approach,** when there are two.
- **Anything the issue leaves open,** grilled in rounds. With several issues, the questions are numbered per issue (6.1, 7.1) so you can answer in one reply.
- **Criterion edits:** if planning finds an acceptance criterion to add, change or remove, the plan proposes it, with the old and new wording. The issue's body changes only if you approve.

## Gotchas

- **Parents aren't planned.** A parent holds no work of its own, so it stops and says to plan its children.
- **A blocked issue can still be planned.** `/build` is what waits for the blocker.
- **The plan names no branch.** `/build` makes it when the build starts.
- **A prototype is recommended, not built.** If a decision needs one, the plan says what it would answer, and building it is separate work.
- **Approve from the chat.** The plan you approve is the one written out there, not a file.

## Why it works this way

- [Why Claude may start it, why plans are written out in full, and why it runs without `workflow.md`](../../decisions/2026-10-16-014625-planning-issues.md).
- [How parent and child issues work](../../decisions/2026-10-15-172511-parent-and-child-issues.md).
- [Why its code reading runs on a cheaper model](../../decisions/2026-10-19-154955-cheaper-lookup-subagents.md).
