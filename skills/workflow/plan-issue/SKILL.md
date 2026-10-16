---
name: plan-issue
description: Turn an issue into an approved plan, posted on the issue as `## Plan (approved)`. Use when Skye asks to plan an issue, or after /draft-issue creates issues she wants planned.
argument-hint: "<N> [<N> …]"
---

# Plan an issue

Turn each issue into a plan Skye approves, then post it on the issue, where `/build` reads it. **Until she approves, this skill only reads:** it posts nothing and edits nothing on GitHub. It never builds and never creates a branch, because `/build` makes the branch when the build starts.

Check every issue first, and stop at the first problem, saying what's wrong and what to do. Put each step below on the task list.

## 0. Read the project's facts

Read `.claude/workflow.md` at the repo root, if it exists. The plan's test section uses **Checks before committing** and **Manual test setup**.

**It's missing, or a section still holds `<placeholders>`:** carry on without it, and say in the plan that the checks come from `/setup-project`. Planning needs no project facts to be right, unlike building or shipping.

This step is done when you know the checks and manual setup, or that there are none.

## 1. Check each issue

For each issue, run `gh issue view <N> --json number,title,state,body,comments`. Then:

- **It isn't open:** stop, and ask whether Skye meant another issue.
- **It's a parent** (step 1 of [finding-the-parent.md](../ship/finding-the-parent.md)): stop, and say to plan its children. A parent holds no work of its own, so there's nothing to plan.
- **It already has a `## Plan (approved)` comment:** ask Skye whether to replan it. The latest plan comment is the one that counts, so a new plan replaces it once approved.
- **It's blocked by an open issue** (`gh api repos/{owner}/{repo}/issues/<N>/dependencies/blocked_by --jq '.[] | select(.state == "open") | "#\(.number) \(.title)"'`): name each blocker, and carry on. A plan can be written before its blocker lands; `/build` is what waits for it.

This step is done when every issue is open and not a parent, Skye has answered about any existing plan, and you've named any blockers.

## 2. Read everything the plan rests on

For each issue, read:

- **the issue and its comments,** for the directive and the acceptance criteria;
- **its parent, if it has one:** the directive, the `**Ships as:**` line, and the sibling issues, whose work is out of scope here;
- **the SPEC.md requirements the issue cites,** if the project has a SPEC.md;
- **CLAUDE.md,** for the project's standards;
- **the code the work affects,** through read-only Explore subagents, so the files stay out of this conversation and several areas can be read at once.

This step is done when you can name every file the work changes, and why.

## 3. Weigh the approaches

- **Non-trivial work** (more than one reasonable way to do it): sketch two approaches, each with its trade-offs, and recommend one, with the reason.
- **Trivial work** (one obvious way): say in one line why one approach is enough.
- **A decision that needs a prototype** to settle (how a screen feels, whether a library fits): recommend the prototype, saying what it would answer, and leave it unbuilt. Building it is separate work for Skye to start.

This step is done when each issue has either two approaches and a recommendation, or a line on why one is enough.

## 4. Show the plan and grill

Write each draft plan out **in full, in the chat reply**, in the format in step 5. Skye reads and approves the plan from the chat, so a plan saved only to a file leaves her nothing to approve. Then, in the same message, after the plans, follow `grilling` for the decisions still open.

**With several issues:** send one message, with each issue's plan in turn, then the questions numbered per issue (6.1, 6.2, 7.1), so Skye can answer them all in one reply.

Each answer goes back into the plan. After each round, write the updated plan out in full again, before any new questions.

This step is done when Skye has approved each plan as written out in the chat.

## 5. The plan's format

```markdown
## Plan (approved)

### Decided while planning

1. <Each decision settled while grilling, with its answer.>

### Approach

<Only when there were two: the one chosen, the one left, and why.>

### Files

1. **`<path>`** (<new, or what changes>): <what, and why>.

### Tests

- <Each behaviour `tdd` will build, phrased so it can be observed, e.g. "a closed month rejects new bookings".>
- **Seams:** <the public paths each behaviour is tested through>.
- **Checks:** <each command under Checks before committing, with the expected result>.

### Test data

<Changes to fixtures, seed files or test settings, or "None".>

### Left out

- <What this issue deliberately doesn't do, and where it goes instead.>

### Proposed criterion edits

<Only if planning found an acceptance criterion to add, change or remove: each one, old and new wording, and why.>
```

The plan names no branch, because `/build` makes it. While it's a draft in the chat, its heading is `## Plan (draft)`.

This step is done when every section is filled in, with no `<placeholders>` left.

## 6. On approval, post it

For each issue Skye approves:

1. Write the plan, headed `## Plan (approved)`, to a file in the scratchpad, and post it: `gh issue comment <N> --body-file <file>`.
2. **Criterion edits she approved:** write the issue's new body to a file in the scratchpad, and apply it: `gh issue edit <N> --body-file <file>`.

This step is done when every approved plan is posted, every approved criterion edit is on its issue, and you have each comment's link.

Hand back with each plan comment's link, and any issue still waiting on Skye. Then suggest `/build <N>` for each approved issue, and stop: only Skye starts a build.
