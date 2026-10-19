# `/whats-next`

Recommends the next issue to work on, with the command to run. It changes nothing.

For the exact steps, see its [SKILL.md](../../skills/workflow/whats-next/SKILL.md).

## When to use it

When you're picking a project back up, after a break or a finished piece of work, and want to know what to do now. Only you start it. It only reads, but it runs a subagent, which takes time and tokens, so the moment to ask is yours.

It works in any project with GitHub issues, even one without `.claude/workflow.md`.

## What you'll see

1. It checks you're starting clean: signed in to `gh`, on the default branch, nothing uncommitted, and not behind GitHub. Otherwise it says what to do (`git switch`, commit or stash, `git pull`) and stops.
2. One subagent reads the open issues, so their text stays out of your conversation.
3. You get a **Next** issue, with its stage, why it's next and its command on a line of its own to copy, then up to four more, and a count of the rest.

### How it ranks issues

It shortlists about five, in this order:

1. **Work already started:** an issue with a branch, an open PR, a handover or a plan.
2. **Bugs.**
3. **The first open child of each parent,** in the parent's order.
4. **Judgement** from titles and labels, such as an issue others depend on.

A blocked issue goes after its open blockers. Children of one parent keep the parent's order, even when a later one is already started.

Each one's **stage** sets its command: needs a plan (`/plan-issue`), ready to build (`/build`), being built (finish, then `/handover`), in review (review, then `/ship`), or ready to merge (`/merge`). A parent that ships as one PR can be listed too, once its children are folded or its PR is open.

## Gotchas

- **On a feature branch,** it stops. A recommendation made there would start the next piece of work from the wrong place.
- **"Next: none"** with open issues left means none can be picked, for example parents whose children are all closed. Look at them on GitHub.

## Why it works this way

- **It only recommends,** because the command it suggests is yours to type: typing it is how you approve that step.
- **It needs a clean, up-to-date default branch,** which removes all the local-state reporting from the answer to "what do I do now?" The same file covers working the stage out each time instead of storing it in labels, reading comments only for the shortlist, and showing at most five: [whats-next](../../decisions/2026-10-17-012844-whats-next.md).
